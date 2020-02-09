import 'package:ginko/loaders/loader.dart';
import 'package:ginko/models/models.dart';
import 'package:ginko/utils/static.dart';

/// CafetoriaLoader class
class CafetoriaLoader extends Loader<Cafetoria> {
  // ignore: public_member_api_docs
  CafetoriaLoader() : super(Keys.cafetoria);

  @override
  bool get alwaysPost => true;

  @override
  Map<String, String> get postBody => {
    'id': Static.storage.getString(Keys.cafetoriaId),
    'pin': Static.storage.getString(Keys.cafetoriaPassword)
  };

  @override
  // ignore: type_annotate_public_apis, always_declare_return_types
  fromJSON(json) => Cafetoria.fromJson(json);
}
