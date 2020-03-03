import 'package:cafetoria/cafetoria.dart';
import 'package:flutter/material.dart';
import 'package:flutter_event_bus/flutter_event_bus.dart';
import 'package:utils/utils.dart';

/// The cafetoria tags synchronization
class CafetoriaTagsHandler extends TagsHandler {
  @override
  void syncFromServer(Tags tags, BuildContext context) {
    bool cafetoriaIsNewer = false;
    final String cafetoriaModified =
        Static.storage.getString(CafetoriaKeys.cafetoriaModified);
    if (cafetoriaModified != null) {
      final DateTime local = DateTime.parse(cafetoriaModified);
      if (tags.cafetoriaLogin.timestamp.isAfter(local)) {
        cafetoriaIsNewer = true;
      }
    } else if (tags.cafetoriaLogin.id != null) {
      cafetoriaIsNewer = true;
    }

    if (cafetoriaIsNewer) {
      if (tags.cafetoriaLogin.id == null) {
        Static.storage.setString(CafetoriaKeys.cafetoriaId, null);
        Static.storage.setString(CafetoriaKeys.cafetoriaPassword, null);
      } else {
        final String decryptedID = decryptText(tags.cafetoriaLogin.id);
        final String decryptedPassword =
            decryptText(tags.cafetoriaLogin.password);
        Static.storage.setString(CafetoriaKeys.cafetoriaId, decryptedID);
        Static.storage
            .setString(CafetoriaKeys.cafetoriaPassword, decryptedPassword);
      }
      Static.storage.setString(CafetoriaKeys.cafetoriaModified,
          tags.cafetoriaLogin.timestamp.toIso8601String());
      EventBus.of(context).publish(CafetoriaUpdateEvent());
    }
  }

  @override
  Map<String, dynamic> syncToServer(Tags tags) {
    final Map<String, dynamic> tagsToUpdate = {};

    final String id = Static.storage.getString(CafetoriaKeys.cafetoriaId);
    final String password =
        Static.storage.getString(CafetoriaKeys.cafetoriaPassword);
    final String lastModified =
        Static.storage.getString(CafetoriaKeys.cafetoriaModified);

    // If the local cafetoria login data is set and newer than the server login data
    if (lastModified != null &&
        DateTime.parse(lastModified).isAfter(tags.cafetoriaLogin.timestamp)) {
      final encryptedId = id == null ? null : encryptText(id);
      final encryptedPassword = password == null ? null : encryptText(password);

      if (tags.cafetoriaLogin.id != encryptedId ||
          tags.cafetoriaLogin.password != encryptedPassword) {
        tagsToUpdate['cafetoria'] = CafetoriaTags(
                id: encryptedId,
                password: encryptedPassword,
                timestamp: DateTime.parse(lastModified))
            .toMap();
      }
    }
    return tagsToUpdate;
  }
}
