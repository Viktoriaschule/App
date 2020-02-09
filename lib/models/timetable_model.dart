import 'package:flutter/material.dart';
import 'package:ginko/models/models.dart';
import 'package:ginko/utils/static.dart';

/// Describes the whole timetable
class Timetable {
  // ignore: public_member_api_docs
  Timetable({@required this.days, @required this.date, @required this.grade}) {
    setAllSelections();
  }

  /// Creates a timetable for json map
  factory Timetable.fromJSON(Map<String, dynamic> json) => Timetable(
        grade: json['grade'],
        date: DateTime.parse(json['date']).toLocal(),
        days: json['data']['days']
            .map((json) => TimetableDay.fromJson(json))
            .cast<TimetableDay>()
            .toList(),
      );

  /// All timetable days
  List<TimetableDay> days;

  /// The updated day of the timetable
  DateTime date;

  /// The grade of the timetable
  String grade;

  /// Set all default selections...
  void setAllSelections() {
    for (int i = 0; i < days.length; i++) {
      days[i].setSelections(days.indexOf(days[i]));
    }
  }

  /// Resets all selection in the timetable
  void resetAllSubstitutions() {
    for (final day in days) {
      for (final unit in day.units) {
        unit.substitutions = [];
        for (final subject in unit.subjects) {
          subject.substitutions = [];
        }
      }
    }
  }

  /// Returns all timetable subjects
  List<TimetableSubject> getAllSubjects() => days
      .map((d) => d.units.map((u) => u.subjects).toList())
      .toList()
      .reduce((i1, i2) => List.from(i1)..addAll(i2))
      .reduce((i1, i2) => List.from(i1)..addAll(i2));

  /// return all selected subjects
  List<TimetableSubject> getAllSelectedSubjects() => days
      .map((day) => day.units.map((unit) => unit.getSelected()).toList())
      .toList()
      .reduce((i1, i2) => List.from(i1)..addAll(i2))
      .where((subject) => subject != null && subject.unit != 5)
      .toList();

  /// Returns all subjects with the given [courseID]
  List<TimetableUnit> getAllSubjectsWithCourseID(String courseID) => days
      .map((day) => day.units
          .where((unit) => unit.subjects
              .map((subject) => subject.courseID)
              .contains(courseID))
          .toList())
      .toList()
      .reduce((i1, i2) => List.from(i1)..addAll(i2));

  /// Get the index of the initial day
  DateTime initialDay(DateTime date) {
    var day = DateTime(
      date.year,
      date.month,
      date.day,
    );
    if (monday(date).isAfter(date)) {
      day = monday(date);
    }
    final lessonCount = days[day.weekday - 1].getUserLessonsCount();
    if (date.isAfter(day.add(Times.getUnitTimes(lessonCount - 1)[1]))) {
      day = day.add(Duration(days: 1));
    }
    if (day.weekday > 5) {
      day = monday(day);
    }
    return day;
  }

  /// Get the time stamp of this object
  int get timeStamp => date.millisecondsSinceEpoch ~/ 1000;
}

/// Describes a day of the timetable
class TimetableDay {
  // ignore: public_member_api_docs
  TimetableDay({@required this.day, @required this.units});

  /// Creates a timetable day from json map
  factory TimetableDay.fromJson(Map<String, dynamic> json) => TimetableDay(
        day: json['day'],
        units: json['units']
            .map((i) => TimetableUnit.fromJson(i, json['day']))
            .cast<TimetableUnit>()
            .toList(),
      );

  /// The weekday (0 to 4)
  final int day;

  /// The list of all timetable units on this day
  final List<TimetableUnit> units;

  /// Returns the lessons on this day for the user
  ///
  /// Without free lesson in the end
  int getUserLessonsCount() {
    for (int i = units.length - 1; i >= 0; i--) {
      final TimetableUnit unit = units[i];
      final TimetableSubject selected =
          Static.selection.getSelectedSubject(unit.subjects);

      // If nothing  or a subject (not lunchtime and free lesson) selected return the index...
      if ((selected == null || selected.subjectID != 'Freistunde') && i != 5) {
        return i + 1;
      }
    }
    return 0;
  }

  /// Set the default selections...
  Future setSelections(int day) async {
    for (int i = 0; i < units.length; i++) {
      units[i].setSelection(day, i);
    }
  }

  /// Returns all equals changes
  List<Substitution> getEqualChanges(
      List<Substitution> changes, Substitution change) {
    changes = changes.where((c) => c != change).toList();
    return changes.where((c) => change.equals(c)).toList();
  }
}

/// Describes a Lesson of a timetable day
class TimetableUnit {
  // ignore: public_member_api_docs
  TimetableUnit({
    @required this.unit,
    @required this.subjects,
    @required this.day,
  });

  /// Creates a timetable unit from json map
  factory TimetableUnit.fromJson(Map<String, dynamic> json, int day) =>
      TimetableUnit(
          unit: json['unit'],
          subjects: json['subjects']
              .map((i) => TimetableSubject.fromJson(i, day))
              .cast<TimetableSubject>()
              .toList(),
          day: day);

  /// The unit number (starts with 0)
  final int unit;

  /// All subject in this unit
  final List<TimetableSubject> subjects;

  /// The day index (0 to 4)
  final int day;

  /// All substitution for this unit
  ///
  /// Here will be only the exams. The other substitutions will be directly in the subject
  List<Substitution> substitutions = [];

  /// Returns the block for all subjects in this unit
  String get block => subjects.isNotEmpty ? subjects[0].block : null;

  /// Set the default selection
  void setSelection(int day, int unit) {
    if (subjects.length == 1) {
      Static.selection.setSelectedSubject(subjects[0], defaultSelection: true);
    }
  }

  /// Return the selected subject
  TimetableSubject getSelected() =>
      Static.selection.getSelectedSubject(subjects);
}

/// Describes a subject of a timetable unit
class TimetableSubject {
  // ignore: public_member_api_docs
  TimetableSubject({
    @required this.unit,
    @required this.id,
    @required this.teacherID,
    @required this.subjectID,
    @required this.roomID,
    @required this.courseID,
    @required this.block,
    @required this.day,
  });

  /// Creates a subject from json map
  factory TimetableSubject.fromJson(Map<String, dynamic> json, int day) =>
      TimetableSubject(
        unit: json['unit'],
        id: json['id'],
        teacherID: json['teacherID'].replaceAll('+', '\n'),
        subjectID: json['subjectID'],
        roomID: json['roomID'],
        courseID: json['courseID'],
        block: json['block'],
        day: day,
      );

  /// The unit index (starts with 0)
  final int unit;

  /// The uniq subject identifier
  final String id;

  /// The subject name identifier
  final String subjectID;

  /// The teacher name identifier
  final String teacherID;

  /// The room name identifier
  final String roomID;

  /// The uniq course identifier
  final String courseID;

  /// The block of the subject
  final String block;

  /// The day index of the subject (0 to 4)
  final int day;

  /// All substitution for this subject
  List<Substitution> substitutions = [];

  /// Returns all changes with this subject id
  List<Substitution> getSubstitutions() => [
        ...?substitutions,
        ...?Static.timetable.data.days[day].units[unit].substitutions
      ];

  /// Check if the exams is already set
  bool get examIsSet => Static.storage.getBool(Keys.exam(subjectID)) != null;

  /// Get writing exams
  bool get writeExams => Static.storage.getBool(Keys.exam(subjectID)) ?? true;

  /// Set writing exams
  set writeExams(bool write) {
    Static.storage.setBool(Keys.exam(subjectID), write);
    Static.storage.setString(
        Keys.examTimestamp(subjectID), DateTime.now().toIso8601String());
  }
}
