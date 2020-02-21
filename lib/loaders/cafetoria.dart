import 'package:flutter/widgets.dart';
import 'package:viktoriaapp/loaders/loader.dart';
import 'package:viktoriaapp/models/models.dart';
import 'package:viktoriaapp/utils/static.dart';

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

  Future<int> checkLogin(String id, String pin, BuildContext context) async {
    final response = await fetch(
      context,
      body: {'id': id, 'pin': pin},
    );
    if (response.statusCode != StatusCodes.success) {
      return StatusCodes.failed;
    }
    if (response.data != null) {
      return response.data.error == null
          ? StatusCodes.success
          : StatusCodes.unauthorized;
    }
    return StatusCodes.failed;
  }

  @override
  // ignore: type_annotate_public_apis, always_declare_return_types
  fromJSON(json) => Cafetoria.fromJson(json);
}
