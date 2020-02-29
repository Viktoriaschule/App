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

  /// Deletes all cafetoria credentials and sync this with the server
  Future<StatusCode> logout(BuildContext context) async {
    // Get current values, for the case that the logout fails
    final id = Static.storage.getString(Keys.cafetoriaId);
    final pin = Static.storage.getString(Keys.cafetoriaPassword);
    final modified = Static.storage.getString(Keys.cafetoriaModified);

    // Remove login data
    Static.storage.remove(Keys.cafetoriaId);
    Static.storage.remove(Keys.cafetoriaPassword);
    Static.storage
        .setString(Keys.cafetoriaModified, DateTime.now().toIso8601String());

    // Sync login data
    await Static.tags.syncTags(context);
    final status = await loadOnline(context, force: true);

    // If the logout was not successfully, restore data
    if (status != StatusCode.success) {
      Static.storage.setString(Keys.cafetoriaId, id);
      Static.storage.setString(Keys.cafetoriaPassword, pin);
      Static.storage.setString(Keys.cafetoriaModified, modified);
    }
    return status;
  }

  /// Checks the cafetoria login data
  Future<StatusCode> checkLogin(
      String id, String pin, BuildContext context) async {
    final response = await fetch(
      context,
      body: {'id': id, 'pin': pin},
    );
    if (response.statusCode == StatusCode.offline) {
      return StatusCode.offline;
    } else if (response.statusCode == StatusCode.wrongFormat) {
      return StatusCode.wrongFormat;
    } else if (response.statusCode != StatusCode.success) {
      return StatusCode.failed;
    }
    if (response.data != null) {
      return response.data['error'] == null
          ? StatusCode.success
          : (response.data['error']
                  .toString()
                  .toLowerCase()
                  .contains('credentials')
              ? StatusCode.unauthorized
              : StatusCode.failed);
    }
    return StatusCode.failed;
  }

  @override
  // ignore: type_annotate_public_apis, always_declare_return_types
  fromJSON(json) => Cafetoria.fromJson(json);
}
