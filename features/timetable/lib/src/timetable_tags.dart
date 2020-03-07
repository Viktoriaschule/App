import 'package:flutter/material.dart';
import 'package:flutter_event_bus/flutter_event_bus.dart';
import 'package:substitution_plan/substitution_plan.dart';
import 'package:timetable/src/timetable_keys.dart';
import 'package:timetable/timetable.dart';
import 'package:utils/utils.dart';

import 'timetable_events.dart';

/// The timetable tags synchronization
class TimetableTagsHandler extends TagsHandler {
  @override
  void syncFromServer(Tags tags, BuildContext context) {
    bool changed = false;
    // Sync selections
    for (final selection in tags.selected) {
      final String selectedCourseId =
          Static.storage.getString(TimetableKeys.selection(selection.block));
      // If the course id changed, check which version is newer
      if (selectedCourseId != selection.courseID) {
        final String selectedTimestamp = Static.storage
            .getString(TimetableKeys.selectionTimestamp(selection.block));
        // If the server is newer, sync the new course id
        if (selectedCourseId == null ||
            selection.timestamp.isAfter(DateTime.parse(selectedTimestamp))) {
          changed = true;
          Static.storage.setString(
              TimetableKeys.selection(selection.block), selection.courseID);
          Static.storage.setString(
              TimetableKeys.selectionTimestamp(selection.block),
              selection.timestamp.toIso8601String());
        }
      }
    }

    // Sync exams
    for (final exam in tags.exams) {
      final bool writing =
      Static.storage.getBool(TimetableKeys.exam(exam.subject));
      // If the course id changed, check which version is newer
      if (writing != exam.writing) {
        final String examTimestamp =
        Static.storage.getString(TimetableKeys.examTimestamp(exam.subject));
        // If the server is newer, sync the new course id
        if (writing == null ||
            exam.timestamp.isAfter(DateTime.parse(examTimestamp))) {
          changed = true;
          Static.storage
              .setBool(TimetableKeys.exam(exam.subject), exam.writing);
          Static.storage.setString(TimetableKeys.examTimestamp(exam.subject),
              exam.timestamp.toIso8601String());
        }
      }
    }

    // Update the substitution plan filter and views if any tag has changed
    if (changed) {
      // Update the substitution plan filter
      final ttLoader = TimetableWidget
          .of(context)
          .feature
          .loader;
      if (ttLoader.hasLoadedData) {
        SubstitutionPlanWidget
            .of(context)
            .feature
            .loader
            .data
            ?.syncWithTimetable(ttLoader.data);
      }

      // Inform all views about new data
      EventBus.of(context).publish(TimetableUpdateEvent());
    }
  }

  @override
  Map<String, dynamic> syncToServer(Tags tags) {
    final Map<String, dynamic> tagsToUpdate = {};
    // Sync selections and exams
    final List<String> keys = Static.storage.getKeys();
    final List<SelectionValue> selections = [];
    final List<Exam> exams = [];

    // Get all selections and exams
    for (final key in keys) {
      // If the preference key is a selection
      if (key.startsWith(TimetableKeys.selection(''))) {
        final selection = SelectionValue(
          block: key.split('-').sublist(1).join('-'),
          courseID: Static.storage.getString(key),
          timestamp: DateTime.parse(
              Static.storage.getString('timestamp-$key') ?? '20000101'),
        );
        // Check if the local selection is newer than the server selection
        final serverSelection =
            tags.selected.where((s) => s.block == selection.block).toList();
        // If the server does not have this selection,
        // or the selection changed and the local version is newer, sync the selection
        if (serverSelection.isEmpty ||
            (serverSelection[0].courseID != selection.courseID &&
                selection.timestamp.isAfter(serverSelection[0].timestamp))) {
          selections.add(selection);
        }
      }
      // If the preference key is an exam
      else if (key.startsWith(TimetableKeys.exam(''))) {
        final exam = Exam(
            subject: key.split('-').sublist(1).join('-'),
            writing: Static.storage.getBool(key),
            timestamp: DateTime.parse(
                Static.storage.getString('timestamp-$key') ?? '20000101'));
        // Check if the local exam is newer than the server exam
        final serverExam =
            tags.exams.where((e) => e.subject == exam.subject).toList();
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

    return tagsToUpdate;
  }
}
