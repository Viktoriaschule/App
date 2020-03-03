library calendar;

import 'package:calendar/src/calendar_info_card.dart';
import 'package:calendar/src/calendar_keys.dart';
import 'package:calendar/src/calendar_loader.dart';
import 'package:calendar/src/calendar_page.dart';
import 'package:flutter/material.dart';
import 'package:utils/utils.dart';

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
  Widget getInfoCard(DateTime date) => CalendarInfoCard(date: date);

  @override
  Widget getPage() => CalendarPage();

  @override
  CalendarWidget getFeatureWidget(Widget child) =>
      CalendarWidget(feature: this, child: child);
}

// ignore: public_member_api_docs
class CalendarWidget extends FeatureWidget<CalendarFeature> {
  // ignore: public_member_api_docs
  const CalendarWidget(
      {@required Widget child, @required CalendarFeature feature})
      : super(child: child, feature: feature);

  /// Find the closest [CalendarWidget] from ancestor tree.
  static CalendarWidget of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<CalendarWidget>();
}
