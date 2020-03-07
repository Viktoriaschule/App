import 'package:flutter/cupertino.dart';
import 'package:substitution_plan/src/substitution_plan_keys.dart';
import 'package:timetable/timetable.dart';
import 'package:utils/utils.dart';

import 'substitution_plan_events.dart';
import 'substitution_plan_model.dart';

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
