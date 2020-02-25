import 'package:viktoriaapp/loaders/loader.dart';
import 'package:viktoriaapp/models/models.dart';
import 'package:viktoriaapp/utils/events.dart';

/// UpdatesLoader class
class UpdatesLoader extends Loader<Updates> {
  // ignore: public_member_api_docs
  UpdatesLoader() : super(Keys.updates, UpdatesUpdateEvent());

  @override
  // ignore: type_annotate_public_apis, always_declare_return_types
  fromJSON(json) => Updates.fromJson(json);
}
