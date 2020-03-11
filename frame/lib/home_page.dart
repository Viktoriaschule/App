import 'dart:async';

import 'package:after_layout/after_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_event_bus/flutter_event_bus.dart';
import 'package:timetable/timetable.dart';
import 'package:utils/utils.dart';

import 'features.dart';

// ignore: public_member_api_docs
class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends Interactor<HomePage> with AfterLayoutMixin {
  DateTime day;
  Future<void> timeUpdates = Future.delayed(Duration(seconds: 0));
  List<Feature> features;

  DateTime getDay(List<Feature> features) {
    // Get the first feature that wants to set the home page day
    for (final feature in features) {
      final date = feature.getHomePageDate();
      if (date != null) {
        return DateTime(date.year, date.month, date.day);
      }
    }
    // If there is no feature to set the day, set the home page to today
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  @override
  Subscription subscribeEvents(EventBus eventBus) =>
      eventBus.respond<TimetableUpdateEvent>((event) => update());

  void update() {
    setState(() => null);
    timeUpdate();
  }

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
    if (features != null) {
      // Get the closest duration
      Duration duration;
      for (final feature in features) {
        final d = feature.durationToHomePageDateUpdate();
        if (d != null &&
            (duration == null || duration.inSeconds > d.inSeconds)) {
          if (d.inSeconds < 0) {
            print('Error in ${feature.name} time update duration: $duration');
          } else {
            duration = d;
          }
        }
      }

      // Only set if there is any feature that wants to update after s specific time
      if (duration != null) {
        // First cancel the current updater
        await cancelTimeUpdate();

        // Set the new updater
        timeUpdates = Future.delayed(duration).then((_) {
          if (mounted) {
            update();
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
  void afterFirstLayout(BuildContext context) {
    features = FeaturesWidget.of(context).features;
    timeUpdate();
  }

  @override
  Widget build(BuildContext context) {
    //final size = getScreenSize(MediaQuery.of(context).size.width);
    // Get the date for the home page
    final day = getDay(features ?? FeaturesWidget.of(context).features);

    final widgetBuilders = FeaturesWidget.of(context)
        .features
        .map((f) => () => f.getInfoCard(day))
        .toList();

    //TODO: if (size == ScreenSize.small) {
    return ListView.builder(
      shrinkWrap: false,
      padding: EdgeInsets.only(bottom: 10),
      itemCount: widgetBuilders.length,
      itemBuilder: (context, index) => widgetBuilders[index](),
    );
    //}
    //TODO: Add other screen sizes
    /*
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
    /return Container();
    */
  }

  // final _screenPadding = 110;
}