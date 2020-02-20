import 'package:after_layout/after_layout.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:viktoriaapp/home/home_page.dart';
import 'package:viktoriaapp/models/models.dart';
import 'package:viktoriaapp/plugins/platform/platform.dart';
import 'package:viktoriaapp/plugins/pwa/pwa.dart';
import 'package:viktoriaapp/settings/settings_page.dart';
import 'package:viktoriaapp/substitution_plan/substitution_plan_page.dart';
import 'package:viktoriaapp/timetable/timetable_page.dart';
import 'package:viktoriaapp/utils/app_bar.dart';
import 'package:viktoriaapp/utils/custom_circular_progress_indicator.dart';
import 'package:viktoriaapp/utils/custom_linear_progress_indicator.dart';
import 'package:viktoriaapp/utils/notifications.dart';
import 'package:viktoriaapp/utils/screen_sizes.dart';
import 'package:viktoriaapp/utils/static.dart';
import 'package:viktoriaapp/utils/theme.dart';

// ignore: public_member_api_docs
class AppPage extends StatefulWidget {
  // ignore: public_member_api_docs
  const AppPage({
    this.page = 1,
    this.loading = true,
    Key key,
  }) : super(key: key);

  // ignore: public_member_api_docs
  final int page;

  // ignore: public_member_api_docs
  final bool loading;

  @override
  State<StatefulWidget> createState() => _AppPageState();
}

class _AppPageState extends State<AppPage>
    with SingleTickerProviderStateMixin, AfterLayoutMixin<AppPage> {
  bool _loading;
  bool _permissionsGranted = true;
  bool _permissionsChecking = false;
  bool _canInstall = false;
  bool _installing = false;
  PWA _pwa;

  Future _fetchData() async {
    setState(() {
      _loading = true;
    });
    try {
      final result =
          await Static.tags.loadOnline(context, force: true, autoLogin: false);
      if (result == StatusCodes.unauthorized) {
        await _launchLogin();
      } else {
        final storedUpdates = Static.updates.data ?? Updates.fromJson({});
        await Static.updates.loadOnline(context, force: true);
        final fetchedUpdates = Static.updates.data;
        Static.updates.parsedData = storedUpdates;

        Static.user.grade = fetchedUpdates.grade;
        final gradeChanged = Static.timetable.data?.grade != Static.user.grade;

        //TODO: Add old app dialog

        // Update all changed data
        if (storedUpdates.subjects != fetchedUpdates.subjects ||
            !Static.subjects.hasLoadedData) {
          if (await Static.subjects.loadOnline(context) ==
              StatusCodes.success) {
            Static.updates.data.subjects = fetchedUpdates.subjects;
          }
        }
        if (storedUpdates.timetable != fetchedUpdates.timetable ||
            gradeChanged ||
            !Static.timetable.hasLoadedData) {
          if (await Static.timetable.loadOnline(context) ==
              StatusCodes.success) {
            Static.updates.data.timetable = fetchedUpdates.timetable;
          }
        }
        await Static.tags.syncTags(context);
        if (mounted) {
          setState(() {});
        }
        if (storedUpdates.substitutionPlan != fetchedUpdates.substitutionPlan ||
            !Static.substitutionPlan.hasLoadedData) {
          if (await Static.substitutionPlan.loadOnline(context) ==
              StatusCodes.success) {
            Static.updates.data.substitutionPlan =
                fetchedUpdates.substitutionPlan;
          }
        }
        if (mounted) {
          setState(() {});
        }
        if (storedUpdates.calendar != fetchedUpdates.calendar ||
            !Static.calendar.hasLoadedData) {
          if (await Static.calendar.loadOnline(context) ==
              StatusCodes.success) {
            Static.updates.data.calendar = fetchedUpdates.calendar;
          }
        }
        await Static.tags.syncTags(context);
        if (mounted) {
          setState(() {});
        }
        if (storedUpdates.aixformation != fetchedUpdates.aixformation ||
            !Static.aiXformation.hasLoadedData) {
          if (await Static.aiXformation.loadOnline(context) ==
              StatusCodes.success) {
            Static.updates.data.aixformation = fetchedUpdates.aixformation;
          }
        }
        await Static.tags.syncTags(context);
        if (mounted) {
          setState(() {});
        }
        if (storedUpdates.cafetoria != fetchedUpdates.cafetoria ||
            !Static.cafetoria.hasLoadedData ||
            (Static.storage.getString(Keys.cafetoriaId) != null &&
                Static.storage.getString(Keys.cafetoriaPassword) != null)) {
          if (await Static.cafetoria.loadOnline(context) ==
              StatusCodes.success) {
            Static.updates.data.cafetoria = fetchedUpdates.cafetoria;
          }
        }
        if (mounted) {
          setState(() {
            _loading = false;
          });
        }
      }
    } on DioError {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future _launchLogin() async {
    await Navigator.of(context).pushReplacementNamed('/${Keys.login}');
  }

  @override
  void initState() {
    _loading = widget.loading;
    if (_loading) {
      Static.updates.loadOffline();
      if (Static.updates.data == null) {
        Static.updates.parsedData = Updates.fromJson({});
      }
      Static.subjects.loadOffline();
      Static.timetable.loadOffline();
      Static.substitutionPlan.loadOffline();
      Static.calendar.loadOffline();
      Static.aiXformation.loadOffline();
      Static.cafetoria.loadOffline();
    }
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Future afterFirstLayout(BuildContext context) async {
    _pwa = PWA();
    if (Platform().isWeb) {
      _permissionsGranted =
          await Static.firebaseMessaging.hasNotificationPermissions();
      _canInstall = _pwa.canInstall();
      setState(() {});
    }
    if (_loading) {
      await _fetchData();
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
            await Static.tags.syncDevice();
            setState(() {
              _permissionsChecking = false;
            });
          },
          child: Icon(
            Icons.notifications_off,
            size: 28,
            color: textColor(context),
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
            color: textColor(context),
          ),
        ),
    ];
    final Map<String, InlinePage> pages = {};
    pages[Keys.substitutionPlan] = InlinePage(
      'Vertretungsplan',
      [
        ...webActions,
        if (Static.user.grade != null)
          InkWell(
            onTap: () {},
            child: Container(
              width: 48,
              child: Center(
                child: Container(
                  padding: EdgeInsets.all(7.5),
                  decoration: BoxDecoration(
                    boxShadow: MediaQuery.of(context).platformBrightness ==
                            Brightness.light
                        ? [
                            BoxShadow(
                              color: Color(0xFFC8C8C8),
                              spreadRadius: 0.5,
                              blurRadius: 1,
                            ),
                          ]
                        : null,
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.all(Radius.circular(24)),
                    border: Border.all(
                      color: textColor(context),
                      width: getScreenSize(MediaQuery.of(context).size.width) ==
                              ScreenSize.small
                          ? 0.5
                          : 1.25,
                    ),
                  ),
                  child: Text(
                    isSeniorGrade(Static.user.grade)
                        ? Static.user.grade.toUpperCase()
                        : Static.user.grade,
                    style: TextStyle(
                      fontSize: 22,
                      color: textColor(context),
                      fontFamily: 'UbuntuMono',
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
      SubstitutionPlanPage(),
    );
    pages[Keys.timetable] = InlinePage(
      'Stundenplan',
      [
        ...webActions,
        IconButton(
          onPressed: () {
            Navigator.of(context).pushNamed('/${Keys.calendar}');
          },
          icon: Icon(
            MdiIcons.calendarMonth,
            size: 28,
            color: textColor(context),
          ),
        ),
      ],
      TimetablePage(),
    );
    pages[Keys.cafetoria] = InlinePage(
      'Cafétoria',
      [
        ...webActions,
        IconButton(
          onPressed: () {
            //TODO: Add cafetoria login
            Scaffold.of(context).showSnackBar(SnackBar(
              content: Text('TODO: Login hinzufügen!'),
            ));
          },
          icon: Icon(
            MdiIcons.account,
            size: 28,
            color: textColor(context),
          ),
        ),
      ],
      null,
    );
    pages[Keys.aiXformation] = InlinePage(
      'AiXformation',
      [...webActions],
      null,
    );
    pages[Keys.calendar] = InlinePage(
      'Kalender',
      [...webActions],
      null,
    );
    pages[Keys.settings] = InlinePage(
      'Einstellungen',
      [],
      SettingsPage(),
    );
    pages[Keys.home] = InlinePage(
      'Startseite',
      [
        ...webActions,
        IconButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (context) => Scaffold(
                  appBar: CustomAppBar(
                    title: pages[Keys.settings].title,
                    actions: pages[Keys.settings].actions,
                  ),
                  body: pages[Keys.settings].content,
                ),
              ),
            );
          },
          icon: Icon(
            Icons.settings,
            size: 28,
            color: textColor(context),
          ),
        ),
      ],
      HomePage(
        pages: pages,
      ),
    );
    return Scaffold(
      body: CustomScrollView(slivers: [
        CustomAppBar(
          title: pages[Keys.home].title,
          actions: pages[Keys.home].actions,
          sliver: true,
          bottom: _loading
              ? CustomLinearProgressIndicator(
                  backgroundColor: Theme.of(context).primaryColor,
                )
              : null,
        ),
        SliverList(
          delegate: SliverChildListDelegate(
            [
              NotificationsWidget(
                fetchData: _fetchData,
              ),
              pages[Keys.home].content
            ],
          ),
        )
      ]),
    );
  }
}

// ignore: public_member_api_docs
class InlinePage {
  // ignore: public_member_api_docs
  InlinePage(
    this.title,
    this.actions,
    this.content,
  );

  // ignore: public_member_api_docs
  final String title;

  // ignore: public_member_api_docs
  final List<Widget> actions;

  // ignore: public_member_api_docs
  final Widget content;
}
