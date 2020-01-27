import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:ginko/loaders/loader.dart';
import 'package:ginko/models/models.dart';
import 'package:ginko/plugins/platform/platform.dart';
import 'package:ginko/utils/encrypt.dart';
import 'package:ginko/utils/static.dart';

/// SubjectsLoader class
class TagsLoader extends Loader<Tags> {
  // ignore: public_member_api_docs
  TagsLoader() : super(Keys.tags);

  @override
  // ignore: type_annotate_public_apis, always_declare_return_types
  fromJSON(json) => Tags.fromJson(json);

  /// Checks if the tags on the server are already initialized
  Future<bool> isInitialized() async {
    await loadOnline(null, force: true);
    return parsedData.isInitialized;
  }

  /// Initialize device tags
  Future syncDevice() async {
    final String id = await Static.firebaseMessaging.getToken();
    final String appVersion = (await rootBundle.loadString('pubspec.yaml'))
        .split('\n')
        .where((line) => line.startsWith('version'))
        .toList()[0]
        .split(':')[1]
        .trim();
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
          ));
      await sendTags({'device': device.toMap()});
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

      // Check if the cafetoria data on the server is newer than the local
      bool cafetoriaIsNewer = false;
      if (tags.isInitialized) {
        final String cafetoriaModified =
            Static.storage.getString(Keys.cafetoriaModified);
        if (cafetoriaModified != null) {
          final DateTime local = DateTime.parse(cafetoriaModified);
          if (tags.cafetoriaLogin.timestamp.isAfter(local)) {
            cafetoriaIsNewer = true;
          }
        } else if (tags.cafetoriaLogin.id != null) {
          cafetoriaIsNewer = true;
        }
      }

      if (cafetoriaIsNewer) {
        if (tags.cafetoriaLogin.id == null) {
          Static.storage.setString(Keys.cafetoriaId, null);
          Static.storage.setString(Keys.cafetoriaPassword, null);
        } else {
          final String decryptedID = decryptText(tags.cafetoriaLogin.id);
          final String decryptedPassword =
              decryptText(tags.cafetoriaLogin.password);
          Static.storage.setString(Keys.cafetoriaId, decryptedID);
          Static.storage.setString(Keys.cafetoriaPassword, decryptedPassword);
        }
        Static.storage.setString(Keys.cafetoriaModified,
            tags.cafetoriaLogin.timestamp.toIso8601String());
      }

      // If the server do not has any data of this user, do not sync
      if (tags.isInitialized) {
        // Sync selections
        for (final selection in tags.selected) {
          final String selectedCourseId =
              Static.storage.getString(Keys.selection(selection.block));
          // If the course id changed, check wich version is newer
          if (selectedCourseId != selection.courseID) {
            final String selectedTimestamp = Static.storage
                .getString(Keys.selectionTimestamp(selection.block));
            // If the server is newer, sync the new course id
            if (selectedCourseId == null ||
                selection.timestamp
                    .isAfter(DateTime.parse(selectedTimestamp))) {
              Static.storage.setString(
                  Keys.selection(selection.block), selection.courseID);
              Static.storage.setString(Keys.selectionTimestamp(selection.block),
                  selection.timestamp.toIso8601String());
            }
          }
        }

        // Sync exams
        for (final exam in tags.exams) {
          final bool writing = Static.storage.getBool(Keys.exam(exam.subject));
          // If the course id changed, check wich version is newer
          if (writing != exam.writing) {
            final String examTimestamp =
                Static.storage.getString(Keys.examTimestamp(exam.subject));
            // If the server is newer, sync the new course id
            if (writing == null ||
                exam.timestamp.isAfter(DateTime.parse(examTimestamp))) {
              Static.storage.setBool(Keys.exam(exam.subject), exam.writing);
              Static.storage.setString(Keys.examTimestamp(exam.subject),
                  exam.timestamp.toIso8601String());
            }
          }
        }
      } else if (autoSync) {
        await syncTags(context, checkSync: false);
      }
    }
    return;
  }

  /// Send tags to server
  Future sendTags(Map<String, dynamic> tags, {BuildContext context}) async {
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
  Future<void> syncTags(BuildContext context,
      {bool syncExams = true,
      bool syncSelections = true,
      bool syncCafetoria = true,
      bool checkSync = true}) async {
    // Get all server tags...
    await loadOnline(context, force: true);
    final Tags allTags = parsedData;
    if (allTags == null) {
      return;
    }

    if (checkSync) {
      await syncWithTags(context: context, tags: allTags, autoSync: false);
    }

    // Get all changed tags
    final Map<String, dynamic> tagsToUpdate = {};

    if (syncExams || syncSelections) {
      final List<String> keys = Static.storage.getKeys();
      final List<SelectionValue> selections = [];
      final List<Exam> exams = [];

      // Get all selections and exams
      for (final key in keys) {
        // If the preference key is a selection
        if (key.startsWith(Keys.selection(''))) {
          final selection = SelectionValue(
            block: key.split('-').sublist(1).join('-'),
            courseID: Static.storage.getString(key),
            timestamp: DateTime.parse(
                Static.storage.getString('timestamp-$key') ?? '20000101'),
          );
          // Check if the local selection is newer than the server selection
          final serverSelection = allTags.selected
              .where((s) => s.block == selection.block)
              .toList();
          // If the server does not have this selection,
          // or the selection changed and the local version is newer, sync the selection
          if (serverSelection.isEmpty ||
              (serverSelection[0].courseID != selection.courseID &&
                  selection.timestamp.isAfter(serverSelection[0].timestamp))) {
            selections.add(selection);
          }
        }
        // If the preference key is an exam
        else if (key.startsWith(Keys.exam(''))) {
          final exam = Exam(
              subject: key.split('-').sublist(1).join('-'),
              writing: Static.storage.getBool(key),
              timestamp: DateTime.parse(
                  Static.storage.getString('timestamp-$key') ?? '20000101'));
          // Check if the local exam is newer than the server exam
          final serverExam =
              allTags.exams.where((e) => e.subject == exam.subject).toList();
          // If the server does not have this exam,
          // or the exam changed and the local version is newer, sync the exam
          if (serverExam.isEmpty ||
              (serverExam[0].writing != exam.writing &&
                  exam.timestamp.isAfter(serverExam[0].timestamp))) {
            exams.add(exam);
          }
        }
      }

      tagsToUpdate['selected'] = selections.map((s) => s.toMap()).toList();
      tagsToUpdate['exams'] = exams.map((e) => e.toMap()).toList();
    }

    if (syncCafetoria) {
      final String id = Static.storage.getString(Keys.cafetoriaId);
      final String password = Static.storage.getString(Keys.cafetoriaPassword);
      final String lastModified =
          Static.storage.getString(Keys.cafetoriaModified);

      // If the local cafetoria login data is set and newer than the server login data
      if (lastModified != null &&
          DateTime.parse(lastModified)
              .isAfter(allTags.cafetoriaLogin.timestamp)) {
        final encryptedId = id == null ? null : encryptText(id);
        final encryptedPassword =
            password == null ? null : encryptText(password);

        if (allTags.cafetoriaLogin.id != encryptedId ||
            allTags.cafetoriaLogin.password != encryptedPassword) {
          tagsToUpdate['cafetoria'] = CafetoriaTags(
                  id: encryptedId,
                  password: encryptedPassword,
                  timestamp: DateTime.parse(lastModified))
              .toMap();
        }
      }
    }

    if ((tagsToUpdate['selected'] != null &&
            tagsToUpdate['selected'].length > 0) ||
        (tagsToUpdate['exams'] != null && tagsToUpdate['exams'].length > 0) ||
        tagsToUpdate['device'] != null ||
        tagsToUpdate['cafetoria'] != null) {
      await sendTags(tagsToUpdate, context: context);
    }
  }
}
