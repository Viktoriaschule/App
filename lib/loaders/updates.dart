import 'package:ginko/loaders/loader.dart';
import 'package:ginko/models/models.dart';

/// UpdatesLoader class
class UpdatesLoader extends Loader<Updates> {
  // ignore: public_member_api_docs
  UpdatesLoader() : super(Keys.updates);

  @override
  // ignore: type_annotate_public_apis, always_declare_return_types
  fromJSON(json) => Updates.fromJson(json);
}
