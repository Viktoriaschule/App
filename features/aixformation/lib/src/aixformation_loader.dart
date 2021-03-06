import 'package:aixformation/aixformation.dart';
import 'package:utils/utils.dart';

/// AiXformationLoader class
class AiXformationLoader extends Loader<AiXformation> {
  // ignore: public_member_api_docs
  AiXformationLoader()
      : super(AiXformationKeys.aixformation, AiXformationUpdateEvent());

  @override
  // ignore: type_annotate_public_apis, always_declare_return_types
  fromJSON(json) => AiXformation.fromJSON(json);
}
