import 'package:after_layout/after_layout.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_event_bus/flutter_event_bus.dart';
import 'package:frame/home/home_page.dart';
import 'package:frame/settings/settings_page.dart';
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

  Future<StatusCode> _fetchData(
      {bool force = false, bool showStatus = true}) async {
    try {
      final result =
          await Static.tags.loadOnline(context, force: true, autoLogin: false);
      if (result == StatusCode.unauthorized) {
        await _launchLogin();
      } else if (result != StatusCode.success) {
        if (showStatus) {
          Scaffold.of(context).showSnackBar(SnackBar(
            content: Text(getStatusCodeMsg(result)),
            action: SnackBarAction(
              label: 'OK',
              onPressed: () => null,
            ),
          ));
        }
      } else {
        // First sync the tags
        await Static.tags.syncDevice(context);
        await Static.tags.syncTags(context);

        // Then check all updates (If there is something new to update)
        final storedUpdates = Static.updates.data ?? Updates.fromJson({});
        await Static.updates.loadOnline(context, force: true);
        final fetchedUpdates = Static.updates.data;
        Static.updates.parsedData = storedUpdates;

        // Sync the local grade with the server
        Static.user.grade = fetchedUpdates.getUpdate(Keys.grade);

        //TODO: Add old app dialog

        // Define all download processes, but do not wait until they are completed
        // The futures will run parallel and after starting all, the programm will wait until all are finished
        final features =
        final downloads = [
          /// Download subject, timetable and substitution plan in the correct order
          (() async => reduceStatusCodes([
                await Static.subjects.update(
                  context,
                  fetchedUpdates,
                  force: force,
                ),
                await Static.timetable.update(
                  context,
                  fetchedUpdates,
                  force: force || gradeChanged,
                ),
                await Static.substitutionPlan.update(
                  context,
                  fetchedUpdates,
                  force: force,
                ),
              ]))(),
          Static.calendar.update(
            context,
            fetchedUpdates,
            force: force,
          ),
          Static.cafetoria.update(
            context,
            fetchedUpdates,
            force: force ||
                (Static.storage.getString(Keys.cafetoriaId) != null &&
                    Static.storage.getString(Keys.cafetoriaPassword) != null),
          ),
          Static.aiXformation.update(
            context,
            fetchedUpdates,
            force: force,
          ),
        ];

        // Wait until all futures are finished
        final codes = await Future.wait(downloads);
        final status = reduceStatusCodes(codes);
        if (status != StatusCode.success) {
          Scaffold.of(context).showSnackBar(
            SnackBar(
              content: Text(getStatusCodeMsg(status)),
              action: SnackBarAction(
                label: 'OK',
                onPressed: () => null,
              ),
            ),
          );
        }
      }
      return result;
    } on DioError {
      return StatusCode.failed;
    }
  }

  Future _launchLogin() async {
    await Navigator.of(context).pushReplacementNamed('/${Keys.login}');
  }

  @override
  Future afterFirstLayout(BuildContext context) async {
    Static.updates.loadOffline(context);
    if (Static.updates.data == null) {
      Static.updates.parsedData = Updates.fromJson({});
    }
    Static.subjects.loadOffline(context);
    Static.timetable.loadOffline(context);
    Static.substitutionPlan.loadOffline(context);
    Static.calendar.loadOffline(context);
    Static.cafetoria.loadOffline(context);
    Static.aiXformation.loadOffline(context);

    _pwa = PWA();
    if (Platform().isWeb) {
      _permissionsGranted =
          await Static.firebaseMessaging.hasNotificationPermissions();
      _canInstall = _pwa.canInstall();
      setState(() {});
    }

    await _fetchData();
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
