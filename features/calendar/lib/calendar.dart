library calendar;

import 'package:calendar/src/calendar_info_card.dart';
import 'package:calendar/src/calendar_keys.dart';
import 'package:calendar/src/calendar_loader.dart';
import 'package:calendar/src/calendar_page.dart';
import 'package:flutter/material.dart';
import 'package:utils/utils.dart';
import 'package:widgets/widgets.dart';

export 'src/calendar_events.dart';
export 'src/calendar_info_card.dart';
export 'src/calendar_loader.dart';
export 'src/calendar_page.dart';

/// The calendar feature
class CalendarFeature implements Feature {
  @override
  final String name = 'Kalender';

  @override
  final String featureKey = CalendarKeys.calendar;

  @override
  final List<Feature> dependsOn = const [];

  @override
  final CalendarLoader loader = CalendarLoader();

  @override
  final NotificationsHandler notificationsHandler = null;

  @override
  final TagsHandler tagsHandler = null;

  @override
  InfoCard getInfoCard(DateTime date) => CalendarInfoCard(date: date);

  @override
  Widget getPage() => CalendarPage(key: ValueKey(featureKey));

  @override
  CalendarWidget getFeatureWidget(Widget child) => CalendarWidget(
        feature: this,
        key: ValueKey(featureKey),
        child: child,
      );

  @override
  DateTime getHomePageDate() {
    if (loader.hasLoadedData && loader.data.events.isNotEmpty) {
      final events = loader.data.getEventsSince(DateTime.now());
      return events.isNotEmpty ? events.first.start : null;
    }
    return null;
  }

  @override
  Duration durationToHomePageDateUpdate() {
    if (loader.hasLoadedData && loader.data.events.isNotEmpty) {
      final events = loader.data.getEventsSince(DateTime.now());
      return events.isNotEmpty
          ? events.first.end.difference(DateTime.now())
          : null;
    }
    return null;
  }
}

// ignore: public_member_api_docs
class CalendarWidget extends FeatureWidget<CalendarFeature> {
  // ignore: public_member_api_docs
  const CalendarWidget(
      {@required Widget child, @required CalendarFeature feature, Key key})
      : super(child: child, feature: feature, key: key);

  /// Find the closest [CalendarWidget] from ancestor tree.
  static CalendarWidget of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<CalendarWidget>();
}
