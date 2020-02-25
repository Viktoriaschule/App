import 'package:viktoriaapp/loaders/loader.dart';
import 'package:viktoriaapp/models/models.dart';
import 'package:viktoriaapp/utils/events.dart';
import 'package:viktoriaapp/utils/static.dart';

/// SubstitutionPlanLoader class
class SubstitutionPlanLoader extends Loader<SubstitutionPlan> {
  // ignore: public_member_api_docs
  SubstitutionPlanLoader() : super(Keys.substitutionPlan, SubstitutionPlanUpdateEvent());

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
