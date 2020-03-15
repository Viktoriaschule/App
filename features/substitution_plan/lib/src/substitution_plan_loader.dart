import 'package:flutter/material.dart';
import 'package:substitution_plan/substitution_plan.dart';
import 'package:timetable/timetable.dart';
import 'package:utils/utils.dart';

/// SubstitutionPlanLoader class
class SubstitutionPlanLoader extends Loader<SubstitutionPlan> {
  // ignore: public_member_api_docs
  SubstitutionPlanLoader()
      : super(SubstitutionPlanKeys.substitutionPlan,
            SubstitutionPlanUpdateEvent());

  /// The current loaded timetable
  Timetable _loadedTimetable;

  @override
  void preLoad(BuildContext context) =>
      _loadedTimetable = TimetableWidget.of(context).feature.loader.data;

  @override
  void afterLoad() => _loadedTimetable != null
      ? data?.syncWithTimetable(_loadedTimetable)
      : null;

  @override
  // ignore: type_annotate_public_apis, always_declare_return_types
  fromJSON(json) => SubstitutionPlan.fromJSON(json);
}
