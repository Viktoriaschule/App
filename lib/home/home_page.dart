import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:ginko/aixformation/aixformation_row.dart';
import 'package:ginko/app/app_page.dart';
import 'package:ginko/cafetoria/cafetoria_row.dart';
import 'package:ginko/calendar/calendar_row.dart';
import 'package:ginko/substitution_plan/substitution_plan_row.dart';
import 'package:ginko/timetable/timetable_page.dart';
import 'package:ginko/timetable/timetable_row.dart';
import 'package:ginko/utils/bottom_navigation.dart';
import 'package:ginko/utils/empty_list.dart';
import 'package:ginko/utils/list_group.dart';
import 'package:ginko/utils/screen_sizes.dart';
import 'package:ginko/utils/size_limit.dart';
import 'package:ginko/utils/static.dart';
import 'package:ginko/models/models.dart';

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
    final changes =
        Static.substitutionPlan.data?.getForDate(day)?.myChanges ?? [];
    final timetableView = Column(
      children: [
        if (Static.timetable.hasLoadedData && Static.selection.isSet())
          ListGroup(
            title: 'Nächste Stunden - ${weekdays[weekday]}',
            counter: subjects.length > 3 ? subjects.length - 3 : 0,
            heroId: 'timetable',
            actions: [
              NavigationAction(
                Icons.expand_more,
                () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (context) => Scaffold(
                        appBar: AppBar(
                          title: Hero(
                            tag: 'title',
                            child: Material(
                              type: MaterialType.transparency,
                              child: Container(
                                width: 200,
                                child: Text(
                                  pages['timetable'].title,
                                  style: TextStyle(
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w100,
                                    fontSize: 22,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          actions: pages['timetable'].actions,
                          automaticallyImplyLeading: false,
                          elevation: 0,
                        ),
                        body: pages['timetable'].content,
                      ),
                    ),
                  );
                },
              ),
            ],
            children: <Widget>[
              SizeLimit(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (subjects.isEmpty ||
                        !Static.timetable.hasLoadedData ||
                        !Static.selection.isSet())
                      EmptyList(title: 'Kein Stundenplan')
                    else
                      ...(subjects.length > 3
                              ? subjects.sublist(0, 3)
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
                                  .where(
                                      (change) => change.unit == subject.unit)
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
          ),
      ],
    );
    final substitutionPlanView = Column(
      children: [
        if (Static.timetable.hasLoadedData && Static.selection.isSet())
          ListGroup(
            heroId: 'substitutionPlan',
            title:
                'Nächste Vertretungen - ${weekdays[Static.timetable.data.initialDay(DateTime.now()).weekday - 1]}',
            counter: changes.length > 3 ? changes.length - 3 : 0,
            actions: [
              NavigationAction(Icons.expand_more, () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (context) => Scaffold(
                      appBar: AppBar(
                        title: Hero(
                          tag: 'title',
                          child: Material(
                            type: MaterialType.transparency,
                            child: Container(
                              width: 200,
                              child: Text(
                                pages['substitutionPlan'].title,
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w100,
                                  fontSize: 22,
                                ),
                              ),
                            ),
                          ),
                        ),
                        actions: pages['substitutionPlan'].actions,
                        automaticallyImplyLeading: false,
                        elevation: 0,
                      ),
                      body: pages['substitutionPlan'].content,
                    ),
                  ),
                );
              }),
            ],
            children: <Widget>[
              if (changes.isEmpty)
                EmptyList(title: 'Keine Änderungen')
              else
                SizeLimit(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (Static.substitutionPlan.hasLoadedData)
                        ...(changes.length > 3
                                ? changes.sublist(0, 3)
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
          ),
      ],
    );
    final aiXformationView = Column(
      children: [
        if (Static.aiXformation.hasLoadedData)
          ListGroup(
            heroId: 'aixformation',
            actions: [
              NavigationAction(Icons.expand_more, () {
                Navigator.of(context).pushNamed('/${Keys.aiXformation}');
              }),
            ],
            title: 'AiXformation',
            counter: Static.aiXformation.data.posts.length -
                (size == ScreenSize.small ? 2 : 3),
            children: <Widget>[
              if (Static.aiXformation.hasLoadedData)
                ...Static.aiXformation.data.posts
                    .sublist(0, size == ScreenSize.small ? 2 : 3)
                    .map((post) => Container(
                          margin: EdgeInsets.all(10),
                          child: AiXformationRow(
                            post: post,
                          ),
                        ))
                    .toList()
                    .cast<Widget>(),
              if (Static.aiXformation.hasLoadedData &&
                  Static.aiXformation.data.posts.isEmpty)
                EmptyList(title: 'Keine Artikel')
            ],
          ),
      ],
    );
    final days = Static.cafetoria.hasLoadedData
        ? (Static.cafetoria.data.days
                .where(
                    (d) => d.date.isAfter(day.subtract(Duration(seconds: 1))))
                .toList()
                  ..sort((a, b) => a.date.compareTo(b.date)))
            .toList()
        : [];
    final cafetoriaWeekday =
        days.isNotEmpty ? weekdays[days[0].date.weekday - 1] : '';
    final bool loggedIn = Static.storage.getString(Keys.cafetoriaId) != null &&
        Static.storage.getString(Keys.cafetoriaPassword) != null;
    final cafetoriaView = Column(
      children: [
        if (Static.cafetoria.hasLoadedData)
          ListGroup(
            heroId: 'cafetoria',
            actions: [
              NavigationAction(Icons.list, () {}),
              NavigationAction(Icons.credit_card, () {}),
            ],
            title: !loggedIn
                ? days.isEmpty ? 'Cafétoria' : 'Cafétoria - $cafetoriaWeekday'
                : days.isEmpty
                    ? 'Cafétoria (${Static.cafetoria.data.saldo}€)'
                    : 'Cafétoria - $cafetoriaWeekday (${Static.cafetoria.data.saldo}€) ',
            counter: days.isNotEmpty ? days[0].menus.length - 3 : 0,
            onTap: () {
              Navigator.of(context).pushNamed('/${Keys.cafetoria}');
            },
            children: <Widget>[
              if (!Static.cafetoria.hasLoadedData || days.isEmpty)
                EmptyList(title: 'Keine Menüs')
              else
                SizeLimit(
                  child: Column(
                    children: (days[0].menus.length > 3
                            ? days[0].menus.sublist(0, 3)
                            : days[0].menus)
                        .map(
                          (menu) => Container(
                            margin: EdgeInsets.all(10),
                            child: CafetoriaRow(
                              day: days[0],
                              menu: menu,
                            ),
                          ),
                        )
                        .toList()
                        .cast<Widget>(),
                  ),
                ),
            ],
          ),
      ],
    );
    final events = Static.calendar.hasLoadedData
        ? (Static.calendar.data
                .getEventsForTimeSpan(day, day.add(Duration(days: 730)))
                  ..sort((a, b) => a.start.compareTo(b.start)))
            .toList()
        : [];
    final calendarView = Column(
      children: [
        if (Static.calendar.hasLoadedData)
          ListGroup(
            title: 'Kalender',
            actions: [
              NavigationAction(Icons.list, () {}),
              NavigationAction(Icons.calendar_today, () {}),
            ],
            counter: events.length - 3,
            onTap: () {
              Navigator.of(context).pushNamed('/${Keys.calendar}');
            },
            children: <Widget>[
              if (!Static.calendar.hasLoadedData || events.isEmpty)
                EmptyList(title: 'Keine Termine')
              else
                SizeLimit(
                  child: Column(
                    children: [
                      ...(events.length > 3 ? events.sublist(0, 3) : events)
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
          ),
      ],
    );
    //TODO: Use a grid and show no data if there is nothing to show
    return Column(
      children: [
        if (size == ScreenSize.small)
          Column(
            children: [
              timetableView,
              substitutionPlanView,
              calendarView,
              cafetoriaView,
              aiXformationView,
            ],
          ),
        if (size == ScreenSize.middle)
          Column(
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
                          child: x,
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
                          child: x,
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
                          child: x,
                        ))
                    .toList()
                    .cast<Widget>(),
              ),
            ],
          ),
        if (size == ScreenSize.big)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              substitutionPlanView,
              timetableView,
              calendarView,
              cafetoriaView,
              aiXformationView,
            ]
                .map((x) => Expanded(
                      flex: 1,
                      child: x,
                    ))
                .toList()
                .cast<Widget>(),
          ),
      ],
    );
  }
}
