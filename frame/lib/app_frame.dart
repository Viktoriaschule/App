import 'package:after_layout/after_layout.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_event_bus/flutter_event_bus.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:utils/utils.dart';
import 'package:widgets/widgets.dart';

import 'features.dart';
import 'home_page.dart';
import 'settings_page.dart';

// ignore: public_member_api_docs
class AppFrame extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _AppFrameState();
}

class _AppFrameState extends Interactor<AppFrame>
    with SingleTickerProviderStateMixin, AfterLayoutMixin<AppFrame> {
  bool _permissionsGranted = true;
  bool _permissionsChecking = false;
  bool _canInstall = false;
  bool _installing = false;
  PWA _pwa;

  @override
  Subscription subscribeEvents(EventBus eventBus) => eventBus
          .respond<FetchAppDataEvent>((event) => _fetchDataWithStatusMsg())
          .respond<PushMaterialPageRouteEvent>((event) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute<void>(
            builder: (context) => event.page,
          ),
          (r) => r.settings.name == '/',
        );
      });

  Future _fetchDataWithStatusMsg(
      {bool force = false, ScaffoldState scaffoldState}) async {
    final scaffold = scaffoldState ?? Scaffold.of(context);
    final status = await _fetchData(force: force);
    if (status != StatusCode.success) {
      scaffold.showSnackBar(
        SnackBar(
          content: Text(getStatusCodeMsg(status)),
          action: SnackBarAction(
            label: AppLocalizations.ok,
            onPressed: () => null,
          ),
        ),
      );
    }
  }

  Future<StatusCode> _fetchData({
    bool force = false,
  }) async {
    try {
      final result =
          await Static.tags.loadOnline(context, force: true, autoLogin: false);
      if (result == StatusCode.unauthorized) {
        await _launchLogin();
        // Do not inform the user about an unauthorized error,
        // because the login screen already tells enough
        return StatusCode.success;
      } else if (result == StatusCode.success) {
        // First sync the tags
        await Static.tags.syncDevice(
          context,
          FeaturesWidget.of(context).features,
        );
        await Static.tags.syncToServer(
          context,
          FeaturesWidget.of(context).features,
        );

        // Then check all updates (If there is something new to update)
        final response = await Static.updates.fetch(context);
        if (response.statusCode != StatusCode.success) {
          return response.statusCode;
        }
        final fetchedUpdates = response.data;
        if (fetchedUpdates == null) {
          return StatusCode.failed;
        }

        // Sync the local grade with the server
        Static.user.grade = fetchedUpdates.getUpdate(Keys.grade);

        //TODO: Move to feature without gui
        await Static.subjects.update(context, fetchedUpdates, force: force);

        //TODO: Add old app dialog

        return _loadData(
          online: true,
          force: force,
          newUpdates: fetchedUpdates,
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
    Updates newUpdates,
  }) async {
    final features = FeaturesWidget.of(context).features;
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
                newUpdates,
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
    await _loadData(online: false);

    _pwa = PWA();
    if (Platform().isWeb) {
      _permissionsGranted =
          await Static.firebaseMessaging.hasNotificationPermissions();
      _canInstall = _pwa.canInstall();
      setState(() {});
    }
    await _fetchDataWithStatusMsg(scaffoldState: scaffold);
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
            await Static.tags.syncDevice(
              context,
              FeaturesWidget.of(context).features,
            );
            setState(() {
              _permissionsChecking = false;
            });
          },
          child: Icon(
            Icons.notifications_off,
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
                  color: ThemeWidget.of(context).textColor,
                ),
              ),
            ],
            sliver: true,
            isLeading: false,
            loadingKeys: [Keys.tags, Keys.subjects, Keys.updates],
          ),
        ],
        body: CustomRefreshIndicator(
          loadOnline: () => _fetchData(force: true),
          child: HomePage(),
        ),
      ),
    );
  }
}
