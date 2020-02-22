import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:viktoriaapp/aixformation/aixformation_info_card.dart';
import 'package:viktoriaapp/app/app_page.dart';
import 'package:viktoriaapp/cafetoria/cafetoria_info_card.dart';
import 'package:viktoriaapp/calendar/calendar_info_card.dart';
import 'package:viktoriaapp/models/models.dart';
import 'package:viktoriaapp/substitution_plan/substitution_plan_info_card.dart';
import 'package:viktoriaapp/timetable/timetable_info_card.dart';
import 'package:viktoriaapp/utils/screen_sizes.dart';
import 'package:viktoriaapp/utils/static.dart';

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
    final List<CafetoriaDay> allDays = Static.cafetoria.hasLoadedData
        ? (Static.cafetoria.data.days.toList()
              ..sort((a, b) => a.date.compareTo(b.date)))
            .toList()
        : [];
    final events = Static.calendar.hasLoadedData
        ? (Static.calendar.data
                .getEventsForTimeSpan(day, day.add(Duration(days: 730)))
                  ..sort((a, b) => a.start.compareTo(b.start)))
            .toList()
        : [];

    final timetableView =
        Static.timetable.hasLoadedData && Static.selection.isSet()
            ? TimetableInfoCard(
                date: day,
                pages: pages,
                subjects: subjects,
                changes: changes,
              )
            : Container();
    final substitutionPlanView =
        Static.timetable.hasLoadedData && Static.selection.isSet()
            ? SubstitutionPlanInfoCard(
                date: day,
                pages: pages,
                changes: changes,
                substitutionPlanDay: spDay,
              )
            : Container();
    final aiXformationView = Static.aiXformation.hasLoadedData
        ? AiXformationInfoCard(
            date: day,
            pages: pages,
          )
        : Container();
    final cafetoriaView = Static.cafetoria.hasLoadedData
        ? CafetoriaInfoCard(
            date: day,
            pages: pages,
            days: allDays,
          )
        : Container();
    final calendarView = Static.calendar.hasLoadedData
        ? CalendarInfoCard(
            date: day,
            pages: pages,
            events: events,
          )
        : Container();

    if (size == ScreenSize.small) {
      return Container(
        color: Theme.of(context).backgroundColor,
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

  // ignore: avoid_field_initializers_in_const_classes
  final _screenPadding = 110;
}
