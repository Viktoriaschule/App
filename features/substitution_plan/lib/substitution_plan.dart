library substitution_plan;

import 'package:flutter/material.dart';
import 'package:substitution_plan/src/substitution_plan_info_card.dart';
import 'package:substitution_plan/src/substitution_plan_keys.dart';
import 'package:substitution_plan/src/substitution_plan_loader.dart';
import 'package:substitution_plan/src/substitution_plan_notifications.dart';
import 'package:substitution_plan/src/substitution_plan_page.dart';
import 'package:timetable/timetable.dart';
import 'package:utils/utils.dart';
import 'package:widgets/widgets.dart';

export 'src/substitution_list.dart';
export 'src/substitution_plan_events.dart';
export 'src/substitution_plan_info_card.dart';
export 'src/substitution_plan_loader.dart';
export 'src/substitution_plan_model.dart';
export 'src/substitution_plan_page.dart';

/// The substitution plan feature
class SubstitutionPlanFeature implements Feature {
  @override
  final String name = 'Vertretungsplan';

  @override
  final String featureKey = SubstitutionPlanKeys.substitutionPlan;

  @override
  final List<Feature> dependsOn = [TimetableFeature()];

  @override
  final SubstitutionPlanLoader loader = SubstitutionPlanLoader();

  @override
  final SubstitutionPlanNotificationsHandler notificationsHandler =
      SubstitutionPlanNotificationsHandler();

  @override
  final TagsHandler tagsHandler = null;

  @override
  InfoCard getInfoCard(DateTime date) => SubstitutionPlanInfoCard(date: date);

  @override
  Widget getPage() => SubstitutionPlanPage(key: ValueKey(featureKey));

  @override
  SubstitutionPlanWidget getFeatureWidget(Widget child) =>
      SubstitutionPlanWidget(
        feature: this,
        key: ValueKey(featureKey),
        child: child,
      );

  @override
  DateTime getHomePageDate() =>
      loader.hasLoadedData && loader.data.days.isNotEmpty
          ? loader.data.days.first.date
          : null;

  @override
  Duration durationToHomePageDateUpdate() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day + 1).difference(now);
  }
}

// ignore: public_member_api_docs
class SubstitutionPlanWidget extends FeatureWidget<SubstitutionPlanFeature> {
  // ignore: public_member_api_docs
  const SubstitutionPlanWidget(
      {@required Widget child,
      @required SubstitutionPlanFeature feature,
      Key key})
      : super(child: child, feature: feature, key: key);

  /// Find the closest [SubstitutionPlanWidget] from ancestor tree.
  static SubstitutionPlanWidget of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<SubstitutionPlanWidget>();
}
