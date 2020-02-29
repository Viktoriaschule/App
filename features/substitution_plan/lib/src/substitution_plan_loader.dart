import 'package:utils/utils.dart';

import 'substitution_plan_model.dart';

/// SubstitutionPlanLoader class
class SubstitutionPlanLoader extends Loader<SubstitutionPlan> {
  // ignore: public_member_api_docs
  SubstitutionPlanLoader()
      : super(Keys.substitutionPlan, SubstitutionPlanUpdateEvent());

  @override
  // ignore: type_annotate_public_apis, always_declare_return_types
  fromJSON(json) => SubstitutionPlan.fromJSON(json);
}
