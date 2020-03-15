library timetable;

import 'package:flutter/material.dart';
import 'package:utils/utils.dart';
import 'package:widgets/widgets.dart';

import 'src/timetable_info_card.dart';
import 'src/timetable_keys.dart';
import 'src/timetable_loader.dart';
import 'src/timetable_localizations.dart';
import 'src/timetable_notifications.dart';
import 'src/timetable_page.dart';
import 'src/timetable_tags.dart';

export 'src/timetable_events.dart';
export 'src/timetable_info_card.dart';
export 'src/timetable_keys.dart';
export 'src/timetable_loader.dart';
export 'src/timetable_localizations.dart';
export 'src/timetable_model.dart';
export 'src/timetable_page.dart';
export 'src/timetable_row.dart';
export 'src/timetable_select_dialog.dart';

/// The timetable feature
class TimetableFeature implements Feature {
  @override
  final String name = TimetableLocalizations.name;

  @override
  final String featureKey = TimetableKeys.timetable;

  @override
  List<String> dependsOn(BuildContext context) => null;

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
