import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:viktoriaapp/aixformation/aixformation_page.dart';
import 'package:viktoriaapp/aixformation/aixformation_row.dart';
import 'package:viktoriaapp/app/app_page.dart';
import 'package:viktoriaapp/cafetoria/cafetoria_page.dart';
import 'package:viktoriaapp/cafetoria/cafetoria_row.dart';
import 'package:viktoriaapp/calendar/calendar_list.dart';
import 'package:viktoriaapp/calendar/calendar_page.dart';
import 'package:viktoriaapp/calendar/calendar_row.dart';
import 'package:viktoriaapp/substitution_plan/substitution_plan_row.dart';
import 'package:viktoriaapp/timetable/timetable_row.dart';
import 'package:viktoriaapp/utils/app_bar.dart';
import 'package:viktoriaapp/utils/bottom_navigation.dart';
import 'package:viktoriaapp/utils/empty_list.dart';
import 'package:viktoriaapp/utils/list_group.dart';
import 'package:viktoriaapp/utils/screen_sizes.dart';
import 'package:viktoriaapp/utils/size_limit.dart';
import 'package:viktoriaapp/utils/static.dart';
import 'package:viktoriaapp/utils/theme.dart';
import 'package:viktoriaapp/models/models.dart';

// ignore: public_member_api_docs
class HomePage extends StatelessWidget {
  // ignore: public_member_api_docs
  const HomePage({@required this.pages});

  // ignore: public_member_api_docs
  final Map<String, InlinePage> pages;

  @override
  Widget build(BuildContext context) {
    final size = getScreenSize(MediaQuery.of(context).size.width);

    // Get the weekday for the home page
    final weekday = Static.timetable.hasLoadedData
        ? Static.timetable.data.initialDay(DateTime.now()).weekday - 1
        : 0;

    // Get the date for the home page
    final day = Static.selection.isSet() && Static.timetable.hasLoadedData
        ? Static.timetable.data.initialDay(DateTime.now())
        : monday(DateTime.now()).add(Duration(days: weekday));

    final subjects = Static.timetable.hasLoadedData
        ? Static.timetable.data.days[weekday].units
            .map((unit) => Static.selection.getSelectedSubject(unit.subjects))
            .where((subject) =>
                subject != null &&
                subject.subjectID != 'Mittagspause' &&
                DateTime.now()
                    .isBefore(day.add(Times.getUnitTimes(subject.unit)[1])))
            .toList()
        : [];

    // Get all changes for the user for the home page date
    final spDay = Static.substitutionPlan.data?.getForDate(day);
    final changes = spDay?.myChanges ?? [];
    final timetableCut = size == ScreenSize.small
        ? 3
        : _calculateCut(context, size == ScreenSize.middle ? 3 : 2);
    final timetableView = Static.timetable.hasLoadedData &&
            Static.selection.isSet()
        ? ListGroup(
            title: 'Nächste Stunden - ${weekdays[weekday]}',
            counter: subjects.length > timetableCut
                ? subjects.length - timetableCut
                : 0,
            heroId: getScreenSize(MediaQuery.of(context).size.width) ==
                    ScreenSize.small
                ? Keys.timetable
                : '${Keys.timetable}-$weekday',
            heroIdNavigation: Keys.timetable,
            actions: [
              NavigationAction(
                Icons.expand_more,
                () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (context) => Scaffold(
                        appBar: CustomAppBar(
                          title: pages[Keys.timetable].title,
                          actions: pages[Keys.timetable].actions,
                        ),
                        body: pages[Keys.timetable].content,
                      ),
                    ),
                  );
                },
              ),
            ],
            children: [
              SizeLimit(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (subjects.isEmpty ||
                        !Static.timetable.hasLoadedData ||
                        !Static.selection.isSet())
                      EmptyList(title: 'Kein Stundenplan')
                    else
                      ...(subjects.length > timetableCut
                              ? subjects.sublist(0, timetableCut)
                              : subjects)
                          .map(
                        (subject) => Container(
                          margin: EdgeInsets.all(10),
                          child: Column(
                            children: [
                              TimetableRow(
                                subject: subject,
                              ),
                              ...changes
                                  .where((substitution) =>
                                      substitution.unit == subject.unit)
                                  .map((substitution) => SubstitutionPlanRow(
                                        substitution: substitution,
                                        showUnit: false,
                                        keepPadding: true,
                                      ))
                                  .toList()
                                  .cast<Widget>(),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          )
        : Container();
    final substitutionPlanCut = size == ScreenSize.small
        ? 3
        : _calculateCut(context, size == ScreenSize.middle ? 3 : 2);
    final substitutionPlanView =
        Static.timetable.hasLoadedData && Static.selection.isSet()
            ? ListGroup(
                heroId: getScreenSize(MediaQuery.of(context).size.width) ==
                        ScreenSize.small
                    ? Keys.substitutionPlan
                    : '${Keys.substitutionPlan}-${Static.substitutionPlan.data.days.indexOf(spDay)}',
                heroIdNavigation: Keys.substitutionPlan,
                title:
                    'Nächste Vertretungen - ${weekdays[Static.timetable.data.initialDay(DateTime.now()).weekday - 1]}',
                counter: changes.length > substitutionPlanCut
                    ? changes.length - substitutionPlanCut
                    : 0,
                actions: [
                  NavigationAction(Icons.expand_more, () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (context) => Scaffold(
                          appBar: CustomAppBar(
                            title: pages[Keys.substitutionPlan].title,
                            actions: pages[Keys.substitutionPlan].actions,
                          ),
                          body: pages[Keys.substitutionPlan].content,
                        ),
                      ),
                    );
                  }),
                ],
                children: [
                  if (changes.isEmpty)
                    EmptyList(title: 'Keine Änderungen')
                  else
                    SizeLimit(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (Static.substitutionPlan.hasLoadedData)
                            ...(changes.length > substitutionPlanCut
                                    ? changes.sublist(0, substitutionPlanCut)
                                    : changes)
                                .map((substitution) => Container(
                                      margin: EdgeInsets.all(10),
                                      child: SubstitutionPlanRow(
                                        substitution: substitution,
                                      ),
                                    ))
                                .toList()
                                .cast<Widget>()
                        ],
                      ),
                    ),
                ],
              )
            : Container();
    final aiXformationCut = size == ScreenSize.small
        ? 3
        : _calculateCut(context, size == ScreenSize.middle ? 3 : 1);
    final aiXformationView = Static.aiXformation.hasLoadedData
        ? ListGroup(
            heroId: Keys.aiXformation,
            actions: [
              NavigationAction(Icons.expand_more, () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (context) => Scaffold(
                      body: AiXformationPage(page: pages[Keys.aiXformation]),
                    ),
                  ),
                );
              }),
            ],
            title: 'AiXformation',
            counter: Static.aiXformation.data.posts.length - aiXformationCut,
            children: [
              if (Static.aiXformation.hasLoadedData &&
                  Static.aiXformation.data.posts.isNotEmpty)
                ...(Static.aiXformation.data.posts.length > aiXformationCut
                        ? Static.aiXformation.data.posts
                            .sublist(0, aiXformationCut)
                        : Static.aiXformation.data.posts)
                    .map((post) => Container(
                          margin: EdgeInsets.all(10),
                          child: AiXformationRow(
                            post: post,
                          ),
                        ))
                    .toList()
                    .cast<Widget>()
              else
                EmptyList(title: 'Keine Artikel')
            ],
          )
        : Container();
    final List<CafetoriaDay> allDays = Static.cafetoria.hasLoadedData
        ? (Static.cafetoria.data.days.toList()
              ..sort((a, b) => a.date.compareTo(b.date)))
            .toList()
        : [];
    final afterDays = allDays
        .where((d) => d.date.isAfter(day.subtract(Duration(seconds: 1))))
        .toList();
    final cafetoriaWeekday =
        afterDays.isNotEmpty ? weekdays[afterDays.first.date.weekday - 1] : '';
    final bool loggedIn = Static.storage.getString(Keys.cafetoriaId) != null &&
        Static.storage.getString(Keys.cafetoriaPassword) != null;
    final cafetoriaCut = size == ScreenSize.small
        ? 3
        : _calculateCut(context, size == ScreenSize.middle ? 3 : 2);
    final cafetoriaView = Static.cafetoria.hasLoadedData
        ? ListGroup(
            heroId: '${Keys.cafetoria}-0',
            heroIdNavigation: Keys.cafetoria,
            actions: [
              NavigationAction(Icons.list, () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (context) => Scaffold(
                      body: CafetoriaPage(page: pages[Keys.cafetoria]),
                    ),
                  ),
                );
              }),
              NavigationAction(Icons.credit_card, () async {
                const url = 'https://www.opc-asp.de/vs-aachen/';
                if (await canLaunch(url)) {
                  await launch(url);
                }
              }),
            ],
            title: !loggedIn
                ? afterDays.isEmpty
                    ? 'Cafétoria'
                    : 'Cafétoria - $cafetoriaWeekday'
                : afterDays.isEmpty
                    ? 'Cafétoria (${Static.cafetoria.data.saldo}€)'
                    : 'Cafétoria - $cafetoriaWeekday (${Static.cafetoria.data.saldo}€) ',
            counter: allDays.length - 1,
            children: [
              if (!Static.cafetoria.hasLoadedData ||
                  afterDays.isEmpty ||
                  afterDays.first.menus.isEmpty)
                EmptyList(title: 'Keine Menüs')
              else
                SizeLimit(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: (afterDays.first.menus.length > cafetoriaCut
                            ? afterDays.first.menus.sublist(0, cafetoriaCut)
                            : afterDays.first.menus)
                        .map(
                          (menu) => Container(
                            margin: EdgeInsets.all(10),
                            child: CafetoriaRow(
                              day: allDays.first,
                              menu: menu,
                            ),
                          ),
                        )
                        .toList()
                        .cast<Widget>(),
                  ),
                ),
            ],
          )
        : Container();
    final events = Static.calendar.hasLoadedData
        ? (Static.calendar.data
                .getEventsForTimeSpan(day, day.add(Duration(days: 730)))
                  ..sort((a, b) => a.start.compareTo(b.start)))
            .toList()
        : [];
    final calendarCut = size == ScreenSize.small
        ? 3
        : _calculateCut(context, size == ScreenSize.middle ? 3 : 2);
    final calendarView = Static.calendar.hasLoadedData
        ? ListGroup(
            heroId: Keys.calendar,
            title: 'Kalender',
            counter: events.length - calendarCut,
            actions: [
              NavigationAction(
                Icons.list,
                () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (context) => Scaffold(
                        body: CalendarList(page: pages[Keys.calendar]),
                      ),
                    ),
                  );
                },
              ),
              NavigationAction(Icons.calendar_today, () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (context) => Scaffold(
                      appBar: CustomAppBar(
                        title: pages[Keys.calendar].title,
                        actions: pages[Keys.calendar].actions,
                      ),
                      body: CalendarPage(page: pages[Keys.calendar]),
                    ),
                  ),
                );
              })
            ],
            children: [
              if (!Static.calendar.hasLoadedData || events.isEmpty)
                EmptyList(title: 'Keine Termine')
              else
                SizeLimit(
                  child: Column(
                    children: [
                      ...(events.length > calendarCut
                              ? events.sublist(0, calendarCut)
                              : events)
                          .map((event) => Container(
                                margin: EdgeInsets.all(10),
                                child: CalendarRow(
                                  event: event,
                                ),
                              ))
                          .toList()
                          .cast<Widget>(),
                    ],
                  ),
                ),
            ],
          )
        : Container();
    if (size == ScreenSize.small) {
      return Container(
        color: backgroundColor(context),
        child: Column(
          children: [
            timetableView,
            substitutionPlanView,
            calendarView,
            cafetoriaView,
            aiXformationView,
          ],
        ),
      );
    }
    if (size == ScreenSize.middle) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              substitutionPlanView,
              timetableView,
            ]
                .map((x) => Expanded(
                      flex: 1,
                      child: SizedBox(
                        height: (MediaQuery.of(context).size.height -
                                _screenPadding) /
                            3,
                        child: x,
                      ),
                    ))
                .toList()
                .cast<Widget>(),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              calendarView,
              cafetoriaView,
            ]
                .map((x) => Expanded(
                      flex: 1,
                      child: SizedBox(
                        height: (MediaQuery.of(context).size.height -
                                _screenPadding) /
                            3,
                        child: x,
                      ),
                    ))
                .toList()
                .cast<Widget>(),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              aiXformationView,
            ]
                .map((x) => Expanded(
                      flex: 1,
                      child: SizedBox(
                        height: (MediaQuery.of(context).size.height -
                                _screenPadding) /
                            3,
                        child: x,
                      ),
                    ))
                .toList()
                .cast<Widget>(),
          ),
        ],
      );
    }
    if (size == ScreenSize.big) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              substitutionPlanView,
              cafetoriaView,
            ]
                .map((x) => SizedBox(
                      height: (MediaQuery.of(context).size.height -
                              _screenPadding) /
                          2,
                      child: x,
                    ))
                .toList()
                .cast<Widget>(),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              timetableView,
              calendarView,
            ]
                .map((x) => SizedBox(
                      height: (MediaQuery.of(context).size.height -
                              _screenPadding) /
                          2,
                      child: x,
                    ))
                .toList()
                .cast<Widget>(),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height - _screenPadding,
            child: aiXformationView,
          ),
        ]
            .map((x) => Expanded(
                  flex: 1,
                  child: x,
                ))
            .toList()
            .cast<Widget>(),
      );
    }
    return Container();
  }

  int _calculateCut(BuildContext context, int parts) =>
      _calculateHeight(context, parts) ~/ 60;

  double _calculateHeight(BuildContext context, int parts) {
    final viewHeight = MediaQuery.of(context).size.height;
    final tabBarHeight = TabBar(
      tabs: const [],
    ).preferredSize.height;
    const padding = 30;
    return (viewHeight - _screenPadding) / parts - tabBarHeight - padding;
  }

  // ignore: avoid_field_initializers_in_const_classes
  final _screenPadding = 110;
}
