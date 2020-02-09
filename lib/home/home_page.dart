import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:ginko/aixformation/aixformation_row.dart';
import 'package:ginko/app/app_page.dart';
import 'package:ginko/cafetoria/cafetoria_row.dart';
import 'package:ginko/calendar/calendar_row.dart';
import 'package:ginko/substitution_plan/substitution_plan_row.dart';
import 'package:ginko/timetable/timetable_row.dart';
import 'package:ginko/utils/list_group_header.dart';
import 'package:ginko/utils/screen_sizes.dart';
import 'package:ginko/utils/size_limit.dart';
import 'package:ginko/utils/static.dart';
import 'package:ginko/models/models.dart';

// ignore: public_member_api_docs
class HomePage extends StatelessWidget {
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
          ListGroupHeader(
            title: 'Nächste Stunden - ${weekdays[weekday]}',
            counter: subjects.length > 3 ? subjects.length - 3 : 0,
            onTap: () {
              Navigator.of(context).pushReplacement(PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    AppPage(
                  page: 2,
                  loading: false,
                ),
              ));
            },
          ),
        SizeLimit(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (subjects.isEmpty ||
                  !Static.timetable.hasLoadedData ||
                  !Static.selection.isSet())
                Container(
                  height: 60,
                  color: Colors.transparent,
                )
              else
                ...(subjects.length > 3 ? subjects.sublist(0, 3) : subjects)
                    .map((subject) => Container(
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
                        )),
            ],
          ),
        ),
      ],
    );
    final substitutionPlanView = Column(
      children: [
        if (Static.timetable.hasLoadedData && Static.selection.isSet())
          ListGroupHeader(
            title:
                'Nächste Vertretungen - ${weekdays[Static.timetable.data.initialDay(DateTime.now()).weekday - 1]}',
            counter: changes.length > 3 ? changes.length - 3 : 0,
            onTap: () {
              Navigator.of(context).pushReplacement(PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    AppPage(
                  page: 0,
                  loading: false,
                ),
              ));
            },
          ),
        if (changes.isEmpty)
          Container(
            height: 60,
            color: Colors.transparent,
          )
        else
          SizeLimit(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (Static.substitutionPlan.hasLoadedData)
                  ...(changes.length > 3 ? changes.sublist(0, 3) : changes)
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
    );
    final aiXformationView = Column(
      children: [
        if (Static.aiXformation.hasLoadedData)
          ListGroupHeader(
            title: 'AiXformation',
            counter: Static.aiXformation.data.posts.length -
                (size == ScreenSize.small ? 2 : 3),
            onTap: () {
              Navigator.of(context).pushNamed('/${Keys.aiXformation}');
            },
          ),
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
    final bool loggedIn = Static.storage.getString(Keys.cafetoriaId) != null &&
        Static.storage.getString(Keys.cafetoriaPassword) != null;
    final cafetoriaView = Column(
      children: [
        if (Static.cafetoria.hasLoadedData)
          ListGroupHeader(
            title: !loggedIn
                ? 'Cafétoria'
                : 'Cafétoria (${Static.cafetoria.data.saldo}€)',
            counter: days.length - 2,
            onTap: () {
              Navigator.of(context).pushNamed('/${Keys.cafetoria}');
            },
          ),
        if (!Static.cafetoria.hasLoadedData || days.isEmpty)
          Container(
            height: 60,
            color: Colors.transparent,
          )
        else
          SizeLimit(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...(days.length > 2 ? days.sublist(0, 2) : days)
                    .map((day) => Column(
                          children: day.menus
                              .map(
                                (menu) => Container(
                                  margin: EdgeInsets.all(10),
                                  child: CafetoriaRow(
                                    day: day,
                                    menu: menu,
                                    showDate: true,
                                  ),
                                ),
                              )
                              .toList()
                              .cast<Widget>(),
                        ))
                    .toList()
                    .cast<Widget>(),
              ],
            ),
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
          ListGroupHeader(
            title: 'Kalender',
            counter: events.length - 3,
            onTap: () {
              Navigator.of(context).pushNamed('/${Keys.calendar}');
            },
          ),
        if (!Static.calendar.hasLoadedData || events.isEmpty)
          Container(
            height: 60,
            color: Colors.transparent,
          )
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
    );
    return Scrollbar(
      child: ListView(
        shrinkWrap: true,
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
      ),
    );
  }
}
