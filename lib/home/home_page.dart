import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_event_bus/flutter_event_bus.dart';
import 'package:viktoriaapp/aixformation/aixformation_info_card.dart';
import 'package:viktoriaapp/cafetoria/cafetoria_info_card.dart';
import 'package:viktoriaapp/calendar/calendar_info_card.dart';
import 'package:viktoriaapp/models/models.dart';
import 'package:viktoriaapp/substitution_plan/substitution_plan_info_card.dart';
import 'package:viktoriaapp/timetable/timetable_info_card.dart';
import 'package:viktoriaapp/utils/events.dart';
import 'package:viktoriaapp/utils/screen_sizes.dart';
import 'package:viktoriaapp/utils/static.dart';

// ignore: public_member_api_docs
class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends Interactor<HomePage> {
  DateTime day;
  Future<void> timeUpdates = Future.delayed(Duration(seconds: 0));

  DateTime getDay() => Static.timetable.hasLoadedData
      ? Static.timetable.data.initialDay(DateTime.now())
      : monday(DateTime.now()).add(Duration(
          days: (DateTime.now().weekday > 5 ? 1 : DateTime.now().weekday) - 1,
        ));

  @override
  Subscription subscribeEvents(EventBus eventBus) =>
      eventBus.respond<TimetableUpdateEvent>((event) => update());

  void update() => setState(() {
        day = getDay();
        timeUpdate();
      });

  /// Cancel the time updater
  Future<void> cancelTimeUpdate() async {
    try {
      // After updating the timeout the future will directly stops
      await timeUpdates.timeout(Duration(seconds: 0));
      // Wait until the future is finished
      await timeUpdates;
    } on TimeoutException {
      // An await throws a timeout when the future was finished after a timeout, so catch them
      return;
    }
  }

  /// Update the time automatically
  Future<void> timeUpdate() async {
    if (Static.timetable.hasLoadedData) {
      final subjects =
          Static.timetable.data.days[day.weekday - 1].getFutureSubjects(day);
      if (subjects.isNotEmpty) {
        // First cancel the current updater
        await cancelTimeUpdate();

        // Get the duration until the next unit ends
        final duration = Times.getUnitTimes(subjects[0].unit)[1];
        final now = DateTime.now();
        final end = DateTime(
            day.year, day.month, day.day, 0, duration.inMinutes, 0, 0, 0);

        // Set the new updater
        timeUpdates = Future.delayed(end.difference(now)).then((_) {
          if (mounted) {
            update();
            timeUpdate();
          }
        });
      }
    }
  }

  @override
  void dispose() {
    cancelTimeUpdate();
    super.dispose();
  }

  @override
  void initState() {
    day = getDay();
    timeUpdate();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = getScreenSize(MediaQuery.of(context).size.width);

    // Get the date for the home page
    final day = Static.selection.isSet() && Static.timetable.hasLoadedData
        ? Static.timetable.data.initialDay(DateTime.now())
        : monday(DateTime.now()).add(Duration(
            days: (DateTime.now().weekday > 5 ? 1 : DateTime.now().weekday) - 1,
          ));

    Widget timetableBuilder() => TimetableInfoCard(date: day);
    Widget substitutionPlanBuilder() => SubstitutionPlanInfoCard(date: day);
    Widget calendarBuilder() => CalendarInfoCard(date: day);
    Widget cafetoriaBuilder() => CafetoriaInfoCard(date: day);
    Widget aixformationBuilder() => AiXformationInfoCard(date: day);

    final widgetBuilders = [
      timetableBuilder,
      substitutionPlanBuilder,
      calendarBuilder,
      cafetoriaBuilder,
      aixformationBuilder,
    ];

    if (size == ScreenSize.small) {
      return ListView.builder(
        padding: EdgeInsets.only(bottom: 10),
        itemCount: widgetBuilders.length,
        itemBuilder: (context, index) => widgetBuilders[index](),
      );
    }
    if (size == ScreenSize.middle) {
      return SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                substitutionPlanBuilder(),
                timetableBuilder(),
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
                calendarBuilder(),
                cafetoriaBuilder(),
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
                aixformationBuilder(),
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
        ),
      );
    }
    if (size == ScreenSize.big) {
      return SingleChildScrollView(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                substitutionPlanBuilder(),
                cafetoriaBuilder(),
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
                timetableBuilder(),
                calendarBuilder(),
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
              child: aixformationBuilder(),
            ),
          ]
              .map((x) => Expanded(
                    flex: 1,
                    child: x,
                  ))
              .toList()
              .cast<Widget>(),
        ),
      );
    }
    return Container();
  }

  final _screenPadding = 110;
}
