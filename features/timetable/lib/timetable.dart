library timetable;

import 'package:flutter/material.dart';
import 'package:timetable/src/timetable_info_card.dart';
import 'package:timetable/src/timetable_keys.dart';
import 'package:timetable/src/timetable_loader.dart';
import 'package:timetable/src/timetable_notifications.dart';
import 'package:timetable/src/timetable_page.dart';
import 'package:utils/utils.dart';

export 'src/timetable_info_card.dart';
export 'src/timetable_loader.dart';
export 'src/timetable_model.dart';
export 'src/timetable_page.dart';

/// The timetable feature
class TimetableFeature implements Feature {
  @override
  final String name = 'Stundenplan';

  @override
  final String featureKey = TimetableKeys.timetable;

  @override
  final List<Feature> dependsOn = const [];

  @override
  final TimetableLoader loader = TimetableLoader();

  @override
  final TimetableNotificationsHandler notificationsHandler =
      TimetableNotificationsHandler();

  @override
  final TagsHandler tagsHandler = null;

  @override
  Widget getInfoCard(DateTime date) => TimetableInfoCard(date: date);

  @override
  Widget getPage() => TimetablePage();

  @override
  TimetableWidget getFeatureWidget(Widget child) =>
      TimetableWidget(feature: this, child: child);
}

// ignore: public_member_api_docs
class TimetableWidget extends FeatureWidget<TimetableFeature> {
  // ignore: public_member_api_docs
  const TimetableWidget(
      {@required Widget child, @required TimetableFeature feature})
      : super(child: child, feature: feature);

  /// Find the closest [TimetableWidget] from ancestor tree.
  static TimetableWidget of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<TimetableWidget>();
}
