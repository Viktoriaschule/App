import 'package:after_layout/after_layout.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_event_bus/flutter_event_bus.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:viktoriaapp/home/home_page.dart';
import 'package:viktoriaapp/models/models.dart';
import 'package:viktoriaapp/plugins/platform/platform.dart';
import 'package:viktoriaapp/plugins/pwa/pwa.dart';
import 'package:viktoriaapp/settings/settings_page.dart';
import 'package:viktoriaapp/utils/events.dart';
import 'package:viktoriaapp/utils/pages.dart';
import 'package:viktoriaapp/utils/static.dart';
import 'package:viktoriaapp/utils/theme.dart';
import 'package:viktoriaapp/widgets/custom_app_bar.dart';
import 'package:viktoriaapp/widgets/custom_circular_progress_indicator.dart';
import 'package:viktoriaapp/widgets/custom_refresh_indicator.dart';

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
      .respond<PushMaterialPageRouteEvent>(
        (event) => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (context) => event.page,
          ),
        ),
      );

  Future<StatusCodes> _fetchData(
      {bool force = false, bool showStatus = true}) async {
    try {
      final result =
          await Static.tags.loadOnline(context, force: true, autoLogin: false);
      if (result == StatusCodes.unauthorized) {
        await _launchLogin();
      } else if (result != StatusCodes.success) {
        if (showStatus) {
          final msg = result == StatusCodes.offline
              ? 'Du bist offline'
              : 'Verbindung zum Server fehlgeschlagen';
          Scaffold.of(context).showSnackBar(SnackBar(
            content: Text(msg),
            action: SnackBarAction(
              label: 'OK',
              onPressed: () => null,
            ),
          ));
        }
      } else {
        // First sync the tags
        await Static.tags.syncTags(context);

        // Then check all updates (If there is something new to update)
        final storedUpdates = Static.updates.data ?? Updates.fromJson({});
        await Static.updates.loadOnline(context, force: true);
        final fetchedUpdates = Static.updates.data;
        Static.updates.parsedData = storedUpdates;

        // Sync the local grade with the server
        Static.user.grade = fetchedUpdates.grade;
        final gradeChanged = Static.timetable.data?.grade != Static.user.grade;

        //TODO: Add old app dialog

        // Define all download processes, but do not wait until they are completed
        // The futures will run parallel and after starting all, the programm will wait until all are finished
        final downloads = [
          /// Download subject, timetable and substitution plan in the correct order
          download(() async {
            if (force ||
                storedUpdates.subjects != fetchedUpdates.subjects ||
                !Static.subjects.hasLoadedData) {
              if (await Static.subjects.loadOnline(context, force: force) ==
                  StatusCodes.success) {
                Static.updates.data.subjects = fetchedUpdates.subjects;
              }
            }
            if (force ||
                storedUpdates.timetable != fetchedUpdates.timetable ||
                gradeChanged ||
                !Static.timetable.hasLoadedData) {
              if (await Static.timetable.loadOnline(context, force: force) ==
                  StatusCodes.success) {
                Static.updates.data.timetable = fetchedUpdates.timetable;
              }
            }
            if (force ||
                storedUpdates.substitutionPlan !=
                    fetchedUpdates.substitutionPlan ||
                !Static.substitutionPlan.hasLoadedData) {
              if (await Static.substitutionPlan
                      .loadOnline(context, force: force) ==
                  StatusCodes.success) {
                Static.updates.data.substitutionPlan =
                    fetchedUpdates.substitutionPlan;
              }
            }
          }),
          // Download the calendar
          download(() async {
            if (force ||
                storedUpdates.calendar != fetchedUpdates.calendar ||
                !Static.calendar.hasLoadedData) {
              if (await Static.calendar.loadOnline(context, force: force) ==
                  StatusCodes.success) {
                Static.updates.data.calendar = fetchedUpdates.calendar;
              }
            }
          }),
          // Download the cafetoria
          download(() async {
            if (force ||
                storedUpdates.cafetoria != fetchedUpdates.cafetoria ||
                !Static.cafetoria.hasLoadedData ||
                (Static.storage.getString(Keys.cafetoriaId) != null &&
                    Static.storage.getString(Keys.cafetoriaPassword) != null)) {
              if (await Static.cafetoria.loadOnline(context, force: force) ==
                  StatusCodes.success) {
                Static.updates.data.cafetoria = fetchedUpdates.cafetoria;
              }
            }
          }),
          // Download the aixformation
          download(() async {
            if (force ||
                storedUpdates.aixformation != fetchedUpdates.aixformation ||
                !Static.aiXformation.hasLoadedData) {
              if (await Static.aiXformation.loadOnline(context, force: force) ==
                  StatusCodes.success) {
                Static.updates.data.aixformation = fetchedUpdates.aixformation;
              }
            }
          }),
        ];

        // Wait until all futures are finished
        // If a future is finished already, the await has no influence
        for (final download in downloads) {
          await download;
        }
      }
      return result;
    } on DioError {
      return StatusCodes.failed;
    }
  }

  Future<void> download(Future<void> Function() downloader) => downloader();

  Future _launchLogin() async {
    await Navigator.of(context).pushReplacementNamed('/${Keys.login}');
  }

  @override
  void didChangeDependencies() {
    if (Static.storage.getBool(Keys.platformBrightness) !=
        (MediaQuery.of(context).platformBrightness == Brightness.dark)) {
      Static.storage.setBool(Keys.platformBrightness,
          MediaQuery.of(context).platformBrightness == Brightness.dark);
      EventBus.of(context).publish(ThemeChangedEvent());
    }
    super.didChangeDependencies();
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
            pageKey: Keys.home,
          ),
        ],
        body: CustomRefreshIndicator(
          loadOnline: () => _fetchData(force: true, showStatus: false),
          child: SingleChildScrollView(
            child: HomePage(),
          ),
        ),
      ),
    );
  }
}
