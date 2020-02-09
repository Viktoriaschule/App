import 'package:after_layout/after_layout.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:ginko/home/home_page.dart';
import 'package:ginko/plugins/platform/platform.dart';
import 'package:ginko/plugins/pwa/pwa.dart';
import 'package:ginko/substitution_plan/substitution_plan_page.dart';
import 'package:ginko/timetable/timetable_page.dart';
import 'package:ginko/utils/notifications.dart';
import 'package:ginko/utils/screen_sizes.dart';
import 'package:ginko/utils/static.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:ginko/models/models.dart';

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
  TabController _tabController;
  int _currentTab = 1;
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
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: _currentTab = widget.page,
    );
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
    _tabController.dispose();
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
          child: CircularProgressIndicator(
            valueColor:
                AlwaysStoppedAnimation<Color>(Theme.of(context).accentColor),
            strokeWidth: 2,
          ),
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
          ),
        ),
      if (_installing)
        FlatButton(
          onPressed: () {},
          child: CircularProgressIndicator(
            valueColor:
                AlwaysStoppedAnimation<Color>(Theme.of(context).accentColor),
            strokeWidth: 2,
          ),
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
          ),
        ),
    ];
    final pages = [
      InlinePage(
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
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFFC8C8C8),
                          spreadRadius: 0.5,
                          blurRadius: 1,
                        ),
                      ],
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.all(Radius.circular(24)),
                      border: Border.all(
                        color: Colors.black,
                        width:
                            getScreenSize(MediaQuery.of(context).size.width) ==
                                    ScreenSize.small
                                ? 0.5
                                : 1.25,
                      ),
                    ),
                    child: Text(
                      isSeniorGrade(Static.user.grade)
                          ? Static.user.grade.toUpperCase()
                          : Static.user.grade,
                      style: GoogleFonts.ubuntuMono(
                        fontSize: 22,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
        SubstitutionPlanPage(),
        Icons.list,
      ),
      InlinePage(
        'Startseite',
        [
          ...webActions,
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed('/${Keys.settings}');
            },
            icon: Icon(
              Icons.settings,
              size: 28,
            ),
          ),
        ],
        HomePage(),
        Icons.home,
      ),
      InlinePage(
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
            ),
          ),
        ],
        TimetablePage(),
        MdiIcons.timetable,
      ),
    ];
    final tabBar = Column(
      children: [
        Container(
          decoration: BoxDecoration(
            boxShadow: getScreenSize(MediaQuery.of(context).size.width) ==
                    ScreenSize.small
                ? [
                    BoxShadow(
                      color: Color(0xFFC8C8C8),
                      spreadRadius: 1.25,
                      blurRadius: 1,
                    ),
                  ]
                : null,
            color: Theme.of(context).primaryColor,
          ),
          child: TabBar(
            controller: _tabController,
            onTap: (index) {
              setState(() {
                _currentTab = _tabController.index = index;
              });
            },
            indicatorColor: getScreenSize(MediaQuery.of(context).size.width) ==
                    ScreenSize.small
                ? Colors.transparent
                : null,
            tabs: pages
                .map((page) => Tab(
                      icon: Icon(
                        page.iconData,
                        color: _currentTab == pages.indexOf(page) &&
                                getScreenSize(
                                        MediaQuery.of(context).size.width) ==
                                    ScreenSize.small
                            ? Theme.of(context).accentColor
                            : Colors.black54,
                      ),
                    ))
                .toList()
                .cast<Widget>(),
          ),
        ),
        if (getScreenSize(MediaQuery.of(context).size.width) !=
            ScreenSize.small)
          Container(
            height: 1,
            margin: EdgeInsets.only(top: 1),
            width: double.infinity,
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Color(0xFFC8C8C8),
                  spreadRadius: 1.25,
                  blurRadius: 1,
                ),
              ],
              color: Theme.of(context).primaryColor,
            ),
          ),
      ],
    );
    return Scaffold(
      appBar: AppBar(
        title: Text(
          pages[_currentTab].title,
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w100,
            fontSize: 22,
          ),
        ),
        automaticallyImplyLeading: false,
        actions: pages[_currentTab].actions,
        elevation: 0,
      ),
      body: Column(
        children: [
          SizedBox(
            height: 3,
            child: _loading
                ? LinearProgressIndicator(
                    backgroundColor: Theme.of(context).primaryColor,
                  )
                : Container(),
          ),
          if (getScreenSize(MediaQuery.of(context).size.width) !=
              ScreenSize.small)
            tabBar,
          Expanded(
            child: Scaffold(
              backgroundColor:
                  Platform().isWeb ? Color.fromARGB(200, 0, 0, 0) : null,
              body: Stack(
                children: [
                  IndexedStack(
                    index: _currentTab,
                    children: pages
                        .map((page) => page.content)
                        .toList()
                        .cast<Widget>(),
                  ),
                  NotificationsWidget(
                    fetchData: _fetchData,
                  ),
                ],
              ),
            ),
          ),
          if (getScreenSize(MediaQuery.of(context).size.width) ==
              ScreenSize.small)
            tabBar,
        ],
      ),
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
    this.iconData,
  );

  // ignore: public_member_api_docs
  final String title;

  // ignore: public_member_api_docs
  final List<Widget> actions;

  // ignore: public_member_api_docs
  final Widget content;

  // ignore: public_member_api_docs
  final IconData iconData;
}
