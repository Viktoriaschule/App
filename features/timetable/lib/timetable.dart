library timetable;

import 'package:flutter/material.dart';
import 'package:timetable/src/timetable_info_card.dart';
import 'package:timetable/src/timetable_keys.dart';
import 'package:timetable/src/timetable_loader.dart';
import 'package:timetable/src/timetable_notifications.dart';
import 'package:timetable/src/timetable_page.dart';
import 'package:timetable/src/timetable_tags.dart';
import 'package:utils/utils.dart';
import 'package:widgets/widgets.dart';

export 'src/timetable_events.dart';
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
  final TimetableTagsHandler tagsHandler = TimetableTagsHandler();

  @override
  InfoCard getInfoCard(DateTime date) => TimetableInfoCard(date: date);

  @override
  Widget getPage() => TimetablePage(key: ValueKey(featureKey));

  @override
  TimetableWidget getFeatureWidget(Widget child) => TimetableWidget(
        feature: this,
        key: ValueKey(featureKey),
        child: child,
      );

  @override
  DateTime getHomePageDate() =>
      loader.hasLoadedData && loader.data.selection.isSet()
          ? loader.data.initialDay(DateTime.now())
          : monday(DateTime.now()).add(Duration(
              days:
                  (DateTime.now().weekday > 5 ? 1 : DateTime.now().weekday) - 1,
            ));

  @override
  Duration durationToHomePageDateUpdate() {
    if (loader.hasLoadedData) {
      final date = getHomePageDate();
      final subjects = loader.data.days[date.weekday - 1]
          .getFutureSubjects(date, loader.data.selection);
      if (subjects.isNotEmpty) {
        // Get the duration until the next unit ends
        final duration = Times.getUnitTimes(subjects[0].unit)[1];
        final now = DateTime.now();
        final end = DateTime(
            date.year, date.month, date.day, 0, duration.inMinutes, 0, 0, 0);

        // Set the new updater
        return end.difference(now);
      }
    }
    return null;
  }
}

// ignore: public_member_api_docs
class TimetableWidget extends FeatureWidget<TimetableFeature> {
  // ignore: public_member_api_docs
  const TimetableWidget(
      {@required Widget child, @required TimetableFeature feature, Key key})
      : super(child: child, feature: feature, key: key);

  /// Find the closest [TimetableWidget] from ancestor tree.
  static TimetableWidget of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<TimetableWidget>();
}
