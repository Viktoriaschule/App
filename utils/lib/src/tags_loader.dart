import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:package_info/package_info.dart';

import '../utils.dart';
import 'events.dart';
import 'keys.dart';
import 'loader.dart';
import 'plugins/platform/platform.dart';
import 'static.dart';
import 'tags_model.dart';

/// SubjectsLoader class
class TagsLoader extends Loader<Tags> {
  // ignore: public_member_api_docs
  TagsLoader() : super(Keys.tags, TagsUpdateEvent());

  @override
  // ignore: type_annotate_public_apis, always_declare_return_types
  fromJSON(json) => Tags.fromJson(json);

  /// Initialize device tags
  Future syncDevice(BuildContext context, List<Feature> features) async {
    String id;
    if (!Platform().isDesktop) {
      id = await Static.firebaseMessaging.getToken();
    }
    final packageInfo = await PackageInfo.fromPlatform();
    final String appVersion =
        '${packageInfo.version}+${packageInfo.buildNumber}';
    final String os = Platform().platformName;
    final Map<String, bool> notifications = {};
    for (final f in features) {
      if (f.notificationsHandler != null) {
        final key = Keys.notifications(f.featureKey);
        notifications[key] = Static.storage.getBool(key) ?? true;
      }
    }
    if (id != null) {
      final Device device = Device(
        firebaseId: id,
        appVersion: appVersion.isEmpty ? null : appVersion,
        os: os,
        deviceSettings: notifications,
        package: packageInfo.packageName,
      );
      await _sendTags({'device': device.toMap()}, context);
    }
  }

  /// Synchronize local data with server tags
  Future<void> _syncFromServer(
    BuildContext context,
    Tags tags,
    List<Feature> features,
  ) async {
    if (tags == null) {
      await loadOnline(context, force: true);
      tags = parsedData;
    }
    if (tags != null) {
      // Sync grade
      Static.user.grade = tags.grade;

      // Set the user group (1 (pupil); 2 (teacher); 4 (developer); 8 (other))
      Static.user.group = tags.group;

      for (final feature in features) {
        if (feature.tagsHandler != null) {
          feature.tagsHandler.syncFromServer(tags, context);
        }
      }
    }
  }

  /// Send tags to server
  Future<StatusCode> _sendTags(
      Map<String, dynamic> tags, BuildContext context) async {
    try {
      return await loadOnline(
        context,
        force: true,
        body: tags,
        post: true,
        store: false,
      );
      // ignore: empty_catches
    } on DioError {
      return StatusCode.failed;
    }
  }

  /// Sync the tags to the server
  Future<StatusCode> syncToServer(BuildContext context, List<Feature> features,
      {bool checkSync = true}) async {
    // Get all server tags...
    final status = await loadOnline(context, force: true);
    final Tags allTags = parsedData;
    if (allTags == null) {
      print('Failed to load tags: $status');
      return reduceStatusCodes([status, StatusCode.failed]);
    }

    if (checkSync) {
      await _syncFromServer(context, allTags, features);
    }

    // Get all changed tags
    final Map<String, dynamic> tagsToUpdate = {};

    for (final feature in features) {
      if (feature.tagsHandler != null) {
        final _tags = feature.tagsHandler.syncToServer(allTags);
        for (final key in _tags.keys) {
          tagsToUpdate[key] = _tags[key];
        }
      }
    }

    if (tagsToUpdate.keys.isNotEmpty &&
        tagsToUpdate.values.where((v) => v != null).isNotEmpty) {
      final result = await _sendTags(tagsToUpdate, context);
      return reduceStatusCodes([status, result]);
    }
    return StatusCode.success;
  }
}
