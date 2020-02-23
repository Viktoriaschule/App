import 'package:flutter/widgets.dart';
import 'package:viktoriaapp/loaders/loader.dart';
import 'package:viktoriaapp/models/models.dart';
import 'package:viktoriaapp/utils/events.dart';
import 'package:viktoriaapp/utils/static.dart';

/// CafetoriaLoader class
class CafetoriaLoader extends Loader<Cafetoria> {
  // ignore: public_member_api_docs
  CafetoriaLoader() : super(Keys.cafetoria, CafetoriaUpdateEvent());

  @override
  bool get alwaysPost => true;

  @override
  Map<String, String> get postBody => {
        'id': Static.storage.getString(Keys.cafetoriaId),
        'pin': Static.storage.getString(Keys.cafetoriaPassword)
      };

  //TODO: Check if offline
  /// Deletes all cafetoria credentials and sync this with the server
  Future<void> logout(BuildContext context) async {
    Static.storage.remove(Keys.cafetoriaId);
    Static.storage.remove(Keys.cafetoriaPassword);
    Static.storage
        .setString(Keys.cafetoriaModified, DateTime.now().toIso8601String());
    await Static.tags
        .syncTags(context, syncExams: false, syncSelections: false);
    await loadOnline(context, force: true);
  }

  /// Checks the cafetoria login data
  Future<int> checkLogin(String id, String pin, BuildContext context) async {
    final response = await fetch(
      context,
      body: {'id': id, 'pin': pin},
    );
    if (response.statusCode != StatusCodes.success) {
      return StatusCodes.failed;
    }
    if (response.data != null) {
      return response.data['error'] == null
          ? StatusCodes.success
          : (response.data['error']
                  .toString()
                  .toLowerCase()
                  .contains('credentials')
              ? StatusCodes.unauthorized
              : StatusCodes.failed);
    }
    return StatusCodes.failed;
  }

  @override
  // ignore: type_annotate_public_apis, always_declare_return_types
  fromJSON(json) => Cafetoria.fromJson(json);
}
