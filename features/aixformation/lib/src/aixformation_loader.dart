import 'package:utils/utils.dart';

import 'aixformation_model.dart';

/// AiXformationLoader class
class AiXformationLoader extends Loader<AiXformation> {
  // ignore: public_member_api_docs
  AiXformationLoader() : super(Keys.aiXformation, AiXformationUpdateEvent());

  @override
  // ignore: type_annotate_public_apis, always_declare_return_types
  fromJSON(json) => AiXformation.fromJSON(json);
}
