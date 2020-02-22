import 'package:flutter/material.dart';
import 'package:flutter_event_bus/flutter_event_bus.dart';
import 'package:viktoriaapp/models/models.dart';
import 'package:viktoriaapp/utils/events.dart';
import 'package:viktoriaapp/utils/static.dart';

// ignore: public_member_api_docs
class Selection {
  /// Returns the selected index for the given week
  int getSelectedIndex(List<TimetableSubject> subjects) {
    if (subjects.isNotEmpty) {
      // If it is the lunch break, it is always the first
      if (subjects[0].unit == 5 || subjects.length == 1) {
        return 0;
      }

      final String selected =
          Static.storage.getString(Keys.selection(subjects[0].block));
      if (selected != null) {
        final pSubjects =
            subjects.where((s) => s.courseID == selected).toList();
        if (pSubjects.length == 1) {
          return subjects.indexOf(pSubjects[0]);
        } else {
          final pFreeLesson =
              subjects.where((s) => s.subjectID == 'Freistunde').toList();
          if (pFreeLesson.length == 1) {
            return subjects.indexOf(pFreeLesson[0]);
          }
        }
      }
    }
    // ignore: avoid_returning_null
    return null;
  }

  /// Return the selected subject of the [subjects] list
  TimetableSubject getSelectedSubject(List<TimetableSubject> subjects) {
    final int index = getSelectedIndex(subjects);
    return index == null ? null : subjects[index];
  }

  /// Set the selected subject
  void setSelectedSubject(TimetableSubject selected, BuildContext context,
      {bool defaultSelection = false}) {
    // If it is a new selection update it
    if (Static.storage.getString(Keys.selection(selected.block)) !=
        selected.courseID) {
      Static.storage
          .setString(Keys.selection(selected.block), selected.courseID);
      Static.storage.setString(Keys.selectionTimestamp(selected.block),
          DateTime.now().toIso8601String());
      if (Static.substitutionPlan.hasLoadedData) {
        Static.substitutionPlan.data.updateFilter();
      }
    }
    if (!defaultSelection) {
      EventBus.of(context).publish(TimetableUpdateEvent());
    }
  }

  /// Checks if the user set any selections yet
  bool isSet() => Static.storage
      .getKeys()
      .where((key) => key.startsWith(Keys.selection('')))
      .isNotEmpty;

  /// Clears all selections
  void clear() {
    Static.storage
        .getKeys()
        .where((key) =>
            key.startsWith(Keys.selection('')) || key.startsWith(Keys.exam('')))
        .forEach((key) => Static.storage.setString(key, null));
  }

  /// Saves the selections to the server
  Future<void> save(BuildContext context) =>
      Static.tags.syncTags(context, syncExams: false, syncCafetoria: false);
}
