import 'package:cafetoria/cafetoria.dart';
import 'package:flutter/material.dart';
import 'package:flutter_event_bus/flutter_event_bus.dart';
import 'package:utils/utils.dart';

import 'cafetoria_events.dart';

/// The cafetoria tags synchronization
class CafetoriaTagsHandler extends TagsHandler {
  @override
  void syncFromServer(Tags tags, BuildContext context) {
    final cafetoriaLogin = CafetoriaTags.fromJson(tags.data['cafetoria']);
    bool cafetoriaIsNewer = false;
    final String cafetoriaModified =
        Static.storage.getString(CafetoriaKeys.cafetoriaModified);
    if (cafetoriaModified != null) {
      final DateTime local = DateTime.parse(cafetoriaModified);
      if (cafetoriaLogin.timestamp.isAfter(local)) {
        cafetoriaIsNewer = true;
      }
    } else if (cafetoriaLogin.id != null) {
      cafetoriaIsNewer = true;
    }

    if (cafetoriaIsNewer) {
      if (cafetoriaLogin.id == null) {
        Static.storage.setString(CafetoriaKeys.cafetoriaId, null);
        Static.storage.setString(CafetoriaKeys.cafetoriaPassword, null);
      } else {
        final String decryptedID = decryptText(cafetoriaLogin.id);
        final String decryptedPassword = decryptText(cafetoriaLogin.password);
        Static.storage.setString(CafetoriaKeys.cafetoriaId, decryptedID);
        Static.storage
            .setString(CafetoriaKeys.cafetoriaPassword, decryptedPassword);
      }
      Static.storage.setString(CafetoriaKeys.cafetoriaModified,
          cafetoriaLogin.timestamp.toIso8601String());
      EventBus.of(context).publish(CafetoriaUpdateEvent());
    }
  }

  @override
  Map<String, dynamic> syncToServer(Tags tags) {
    final cafetoriaLogin = CafetoriaTags.fromJson(tags.data['cafetoria']);
    final Map<String, dynamic> tagsToUpdate = {};

    final String id = Static.storage.getString(CafetoriaKeys.cafetoriaId);
    final String password =
    Static.storage.getString(CafetoriaKeys.cafetoriaPassword);
    final String lastModified =
    Static.storage.getString(CafetoriaKeys.cafetoriaModified);

    // If the local cafetoria login data is set and newer than the server login data
    if (lastModified != null &&
        DateTime.parse(lastModified).isAfter(cafetoriaLogin.timestamp)) {
      final encryptedId = id == null ? null : encryptText(id);
      final encryptedPassword = password == null ? null : encryptText(password);

      if (cafetoriaLogin.id != encryptedId ||
          cafetoriaLogin.password != encryptedPassword) {
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

/// Describes the cafetoria tags
class CafetoriaTags {
  // ignore: public_member_api_docs
  CafetoriaTags({this.id, this.password, this.timestamp});

  /// Creates cafetoria tags from json map
  factory CafetoriaTags.fromJson(Map<String, dynamic> json) =>
      CafetoriaTags(
          id: json['id'],
          password: json['password'],
          timestamp: DateTime.parse(json['timestamp']));

  // ignore: public_member_api_docs
  final String id;

  // ignore: public_member_api_docs
  final String password;

  /// Last updated timestamp
  final DateTime timestamp;

  /// Converts cafetoria tags to json map
  Map<String, dynamic> toMap() =>
      {
        'id': id,
        'password': password,
        'timestamp': timestamp.toIso8601String()
      };
}
