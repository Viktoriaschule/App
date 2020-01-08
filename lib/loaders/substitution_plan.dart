import 'package:ginko/loaders/loader.dart';
import 'package:ginko/models/models.dart';
import 'package:ginko/utils/static.dart';

/// SubstitutionPlanLoader class
class SubstitutionPlanLoader extends Loader<SubstitutionPlan> {
  // ignore: public_member_api_docs
  SubstitutionPlanLoader() : super(Keys.substitutionPlan);

  @override
  // ignore: type_annotate_public_apis, always_declare_return_types
  fromJSON(json) {
    // Reset all the old inserted substitutions
    if (Static.timetable.data != null) {
      Static.timetable.data.resetAllSubstitutions();
    }
    return SubstitutionPlan(
      days: json
          .map<SubstitutionPlanDay>((day) => SubstitutionPlanDay.fromJson(day))
          .toList(),
    );
  }
}
