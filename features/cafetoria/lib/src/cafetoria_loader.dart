import 'package:cafetoria/cafetoria.dart';
import 'package:flutter/widgets.dart';
import 'package:utils/utils.dart';

import 'cafetoria_model.dart';

/// CafetoriaLoader class
class CafetoriaLoader extends Loader<Cafetoria> {
  // ignore: public_member_api_docs
  CafetoriaLoader() : super(CafetoriaKeys.cafetoria, CafetoriaUpdateEvent());

  @override
  bool get alwaysPost => true;

  @override
  bool get forceUpdate =>
      // Always update the data if there are cafetoria credentials
      Static.storage.getString(CafetoriaKeys.cafetoriaId) != null &&
      Static.storage.getString(CafetoriaKeys.cafetoriaPassword) != null;

  @override
  Map<String, String> get postBody => {
        'id': Static.storage.getString(CafetoriaKeys.cafetoriaId),
        'pin': Static.storage.getString(CafetoriaKeys.cafetoriaPassword)
      };

  /// Deletes all cafetoria credentials and sync this with the server
  Future<StatusCode> logout(BuildContext context) async {
    // Get current values, for the case that the logout fails
    final id = Static.storage.getString(CafetoriaKeys.cafetoriaId);
    final pin = Static.storage.getString(CafetoriaKeys.cafetoriaPassword);
    final modified = Static.storage.getString(CafetoriaKeys.cafetoriaModified);

    // Remove login data
    Static.storage.remove(CafetoriaKeys.cafetoriaId);
    Static.storage.remove(CafetoriaKeys.cafetoriaPassword);
    Static.storage.setString(
        CafetoriaKeys.cafetoriaModified, DateTime.now().toIso8601String());

    // Sync login data
    await Static.tags.syncTags(context);
    final status = await loadOnline(context, force: true);

    // If the logout was not successfully, restore data
    if (status != StatusCode.success) {
      Static.storage.setString(CafetoriaKeys.cafetoriaId, id);
      Static.storage.setString(CafetoriaKeys.cafetoriaPassword, pin);
      Static.storage.setString(CafetoriaKeys.cafetoriaModified, modified);
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
