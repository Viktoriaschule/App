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
  Future syncDevice(BuildContext context) async {
    final String id = await Static.firebaseMessaging.getToken();
    final packageInfo = await PackageInfo.fromPlatform();
    final String appVersion =
        '${packageInfo.version}+${packageInfo.buildNumber}';
    final String os = Platform().platformName;
    if (id != null) {
      final Device device = Device(
          firebaseId: id,
          appVersion: appVersion.isEmpty ? null : appVersion,
          os: os,
          name: '-',
          deviceSettings: DeviceSettings(
            spNotifications:
                Static.storage.getBool(Keys.substitutionPlanNotifications) ??
                    true,
            cafNotifications:
                Static.storage.getBool(Keys.cafetoriaNotifications) ?? true,
            axfNotifications:
                Static.storage.getBool(Keys.aiXformationNotifications) ?? true,
          ));
      await sendTags({'device': device.toMap()}, context);
    }
  }

  /// Synchronize local data with server tags
  Future<void> syncWithTags(
      {BuildContext context,
      Tags tags,
      bool autoSync = true,
      bool forceSync = false}) async {
    if (tags == null) {
      await loadOnline(context, force: true);
      tags = parsedData;
    }
    if (tags != null) {
      // Sync grade
      Static.user.grade = tags.grade;

      // Set the user group (1 (pupil); 2 (teacher); 4 (developer); 8 (other))
      Static.user.group = tags.group;

      //TODO: Sync all feature tags loader if the tags are initialized

    } else if (autoSync) {
      await syncTags(context, checkSync: false);
    }
    return;
  }

  /// Send tags to server
  Future sendTags(Map<String, dynamic> tags, BuildContext context) async {
    try {
      await loadOnline(
        context,
        force: true,
        body: tags,
        post: true,
        store: false,
      );
      // ignore: empty_catches
    } on DioError {}
  }

  /// Sync the tags
  Future<StatusCode> syncTags(BuildContext context,
      {bool checkSync = true}) async {
    // Get all server tags...
    final status = await loadOnline(context, force: true);
    final Tags allTags = parsedData;
    if (allTags == null) {
      return reduceStatusCodes([status, StatusCode.failed]);
    }

    if (checkSync) {
      await syncWithTags(context: context, tags: allTags, autoSync: false);
    }

    // Get all changed tags
    final Map<String, dynamic> tagsToUpdate = {};

    ///TODO: Get all tags to sync from each feature

    if (tagsToUpdate.keys.isNotEmpty &&
        tagsToUpdate.values.where((v) => v != null).isNotEmpty) {
      final result = await sendTags(tagsToUpdate, context);
      return reduceStatusCodes([status, result]);
    }
    return StatusCode.success;
  }
}
