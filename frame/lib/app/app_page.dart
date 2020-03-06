import 'package:after_layout/after_layout.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_event_bus/flutter_event_bus.dart';
import 'package:frame/home/home_page.dart';
import 'package:frame/settings/settings_page.dart';
import 'package:frame/utils/features.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:utils/utils.dart';
import 'package:widgets/widgets.dart';

// ignore: public_member_api_docs
class AppPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _AppPageState();
}

class _AppPageState extends Interactor<AppPage>
    with SingleTickerProviderStateMixin, AfterLayoutMixin<AppPage> {
  bool _permissionsGranted = true;
  bool _permissionsChecking = false;
  bool _canInstall = false;
  bool _installing = false;
  PWA _pwa;

  @override
  Subscription subscribeEvents(EventBus eventBus) => eventBus
          .respond<FetchAppDataEvent>((event) => _fetchData())
          .respond<PushMaterialPageRouteEvent>((event) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute<void>(
            builder: (context) => event.page,
          ),
          (r) => r.settings.name == '/',
        );
      });

  Future<StatusCode> _fetchData({
    bool force = false,
    bool showStatus = true,
  }) async {
    try {
      final result =
          await Static.tags.loadOnline(context, force: true, autoLogin: false);
      if (result == StatusCode.unauthorized) {
        await _launchLogin();
      } else if (result == StatusCode.success) {
        // First sync the tags
        await Static.tags.syncDevice(context);
        await Static.tags.syncToServer(
          context,
          FeaturesWidget.of(context).features,
        );

        // Then check all updates (If there is something new to update)
        final storedUpdates = Static.updates.data ?? Updates.fromJson({});
        await Static.updates.loadOnline(context, force: true);
        final fetchedUpdates = Static.updates.data;
        Static.updates.parsedData = storedUpdates;

        // Sync the local grade with the server
        Static.user.grade = fetchedUpdates.getUpdate(Keys.grade);

        //TODO: Move to feature without gui
        await Static.subjects.update(context, fetchedUpdates, force: force);

        //TODO: Add old app dialog

        return _loadData(
          online: true,
          force: force,
        );
      }
      return result;
    } on DioError {
      print('Failed to fetch data');
      return StatusCode.failed;
    }
  }

  Future<StatusCode> _loadData({
    @required bool online,
    bool force = false,
  }) async {
    final features = FeaturesWidget
        .of(context)
        .features;
    final List<String> loading = [];
    final List<String> loaded = [];

    Future<StatusCode> loadFeatures() async {
      // Get all downloader that can be downloaded with the given dependency
      final List<Future<StatusCode>> downloads = [];
      for (final feature in features) {
        // Download the feature if it does not has any dependencies or if all of them are loaded
        if (feature.featureKey.isEmpty ||
            (feature
                .dependsOn(context)
                ?.map(loaded.contains)
                ?.reduce((v1, v2) => v1 || v2) ??
                true)) {
          if (loading.contains(feature.featureKey)) {
            continue;
          }
          loading.add(feature.featureKey);

          // Add the downloader for this feature
          downloads.add(() async {
            // Download online or offline
            StatusCode status;
            if (online) {
              status = await feature.loader.update(
                context,
                Static.updates.data,
                force: force,
              );
            } else {
              status = feature.loader.loadOffline(context);
            }

            loaded.add(feature.featureKey);

            // Return the combined status of this download and all downloads that can now be downloaded because of this download
            return reduceStatusCodes([status, await loadFeatures()]);
          }());
        }
      }

      // Wait for all downloader
      final results = await Future.wait(downloads);
      return reduceStatusCodes(results);
    }

    return loadFeatures();
  }

  Future _launchLogin() async {
    await Navigator.of(context).pushReplacementNamed('/${Keys.login}');
  }

  @override
  Future afterFirstLayout(BuildContext context) async {
    final scaffold = Scaffold.of(context);
    Static.updates.loadOffline(context);
    if (Static.updates.data == null) {
      Static.updates.parsedData = Updates.fromJson({});
    }
    Static.subjects.loadOffline(context);

    _pwa = PWA();
    if (Platform().isWeb) {
      _permissionsGranted =
          await Static.firebaseMessaging.hasNotificationPermissions();
      _canInstall = _pwa.canInstall();
      setState(() {});
    }
    await _loadData(online: false);
    final onlineStatusCode = await _fetchData();
    if (onlineStatusCode != StatusCode.success) {
      scaffold.showSnackBar(
        SnackBar(
          content: Text(getStatusCodeMsg(onlineStatusCode)),
          action: SnackBarAction(
            label: 'OK',
            onPressed: () => null,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final webActions = [
      if (_permissionsChecking)
        FlatButton(
          onPressed: () {},
          child: CustomCircularProgressIndicator(),
        ),
      if (!_permissionsGranted && !_permissionsChecking)
        FlatButton(
          onPressed: () async {
            setState(() {
              _permissionsChecking = true;
            });
            _permissionsGranted =
                await Static.firebaseMessaging.requestNotificationPermissions();
            await Static.tags.syncDevice(context);
            setState(() {
              _permissionsChecking = false;
            });
          },
          child: Icon(
            Icons.notifications_off,
            size: 28,
            color: ThemeWidget.of(context).textColor,
          ),
        ),
      if (_installing)
        FlatButton(
          onPressed: () {},
          child: CustomCircularProgressIndicator(),
        ),
      if (_canInstall && !_installing)
        FlatButton(
          onPressed: () async {
            setState(() {
              _installing = true;
            });
            await _pwa.install();
            _canInstall = _pwa.canInstall();
            setState(() {
              _installing = false;
            });
          },
          child: Icon(
            MdiIcons.cellphoneArrowDown,
            size: 28,
            color: ThemeWidget.of(context).textColor,
          ),
        ),
    ];
    final pages = Pages.of(context).pages;
    return Scaffold(
      extendBody: true,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxScrolled) => [
          CustomAppBar(
            title: pages[Keys.home].title,
            actions: [
              ...webActions,
              IconButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (context) => SettingsPage(),
                    ),
                  );
                },
                icon: Icon(
                  Icons.settings,
                  size: 28,
                  color: ThemeWidget.of(context).textColor,
                ),
              ),
            ],
            sliver: true,
            isLeading: false,
            loadingKeys: [Keys.tags, Keys.subjects, Keys.updates],
          ),
        ],
        body: LayoutBuilder(
          builder: (context, constraints) => CustomRefreshIndicator(
            loadOnline: () => _fetchData(force: true, showStatus: false),
            child: HomePage(),
          ),
        ),
      ),
    );
  }
}
