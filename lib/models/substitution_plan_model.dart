import 'package:flutter/material.dart';
import 'package:viktoriaapp/models/models.dart';
import 'package:viktoriaapp/utils/static.dart';

/// Describes the substitution plan
class SubstitutionPlan {
  // ignore: public_member_api_docs
  SubstitutionPlan({@required this.days});

  // ignore: public_member_api_docs
  factory SubstitutionPlan.fromJSON(List<dynamic> json) {
    if (Static.timetable.data != null) {
      Static.timetable.data.resetAllSubstitutions();
    }
    return SubstitutionPlan(
      days: json
          .map<SubstitutionPlanDay>((day) => SubstitutionPlanDay.fromJson(day))
          .toList(),
    );
  }

  /// All substitution plan days
  final List<SubstitutionPlanDay> days;

  /// Updates the substitution plan filter
  void updateFilter() {
    for (final day in days) {
      day.filterSubstitutions();
    }
  }

  /// Inserts the substitution plan into the timetable
  void insert() {
    Static.timetable.data.resetAllSubstitutions();
    for (final day in days) {
      day.insertInTimetable();
    }
  }

  /// Returns the correct substitution plan day for a given day.
  ///
  /// If there is no substitution plan day available, the function returns null
  SubstitutionPlanDay getForDate(DateTime date) {
    final pDays = days
        .where((day) =>
            day.date.weekday == date.weekday && day.date.day == date.day)
        .toList();
    return pDays.isEmpty ? null : pDays.length == 1 ? pDays[0] : null;
  }
}

/// Describes a day of the substitution plan...
class SubstitutionPlanDay {
  // ignore: public_member_api_docs
  SubstitutionPlanDay(
      {@required this.date,
      @required this.updated,
      @required this.data,
      @required this.week,
      @required this.unparsed,
      @required this.isEmpty}) {
    if (isEmpty) {
      return;
    }
    sort();
    insertInTimetable();
    filterSubstitutions();
    filterUnparsed();
  }

  /// Create substitution from json map
  factory SubstitutionPlanDay.fromJson(Map<String, dynamic> json) =>
      SubstitutionPlanDay(
        date: DateTime.parse(json['date']).toLocal(),
        updated: DateTime.parse(json['updated']).toLocal(),
        unparsed: json['unparsed'].map<String, List<String>>((key, value) =>
            MapEntry<String, List<String>>(key, value.cast<String>())),
        data: json['data'].map<String, List<Substitution>>((key, value) =>
            MapEntry<String, List<Substitution>>(
                key,
                value
                    .map<Substitution>((json) => Substitution.fromJson(json))
                    .toList())),
        week: json['week'],
        isEmpty: false,
      );

  /// The [date] of the day
  final DateTime date;

  /// The [updated] date of the day
  final DateTime updated;

  /// The (A: 0; B: 1) [week]
  final int week;

  /// All unparsed substitutions in a grade map (+other for undefined grade)
  final Map<String, List<String>> unparsed;

  /// All substitutions in a grade map
  final Map<String, List<Substitution>> data;

  /// Is an empty day
  final bool isEmpty;

  /// The filtered substitutions for the user
  List<Substitution> myChanges;

  /// The undefined filtered substitutions
  List<Substitution> undefinedChanges;

  /// The other filtered substitutions
  List<Substitution> otherChanges;

  /// The filtered unparsed substitutions
  List<String> myUnparsed;

  /// The current user grade
  String filteredGrade;

  /// Sorts all substitutions by the unit
  void sort() {
    data.forEach((grade, substitutions) {
      substitutions.sort(
          (s1, s2) => s1.unit < s2.unit ? -1 : s1.unit == s2.unit ? 0 : 1);
    });
  }

  /// Insert the substitutions into the timetable
  void insertInTimetable() {
    final List<TimetableSubject> subjects =
        Static.timetable.data.getAllSubjects();
    final List<String> subjectsIds = subjects.map((s) => s.id).toList();
    final List<String> subjectsCourseIDs =
        subjects.map((s) => s.courseID).toList();

    filteredGrade = Static.timetable.data.grade;
    for (final substitution in data[filteredGrade]) {
      if (substitution.id != null && subjectsIds.contains(substitution.id)) {
        subjects[subjectsIds.indexOf(substitution.id)]
            .substitutions
            .add(substitution);
      } else if (substitution.courseID != null &&
          subjectsCourseIDs.contains(substitution.courseID)) {
        final List<TimetableSubject> _subjects =
            subjects.where((s) => s.courseID == substitution.courseID).toList();
        if (_subjects.isNotEmpty) {
          if (Static.timetable.data.days[date.weekday - 1].units.length <=
              substitution.unit) {
            return;
          }
          Static.timetable.data.days[date.weekday - 1].units[substitution.unit]
              .substitutions
              .add(substitution);
        }
      }
    }
  }

  /// Set the unparsed filtered lists
  List<String> filterUnparsed({String grade}) {
    myUnparsed = [];
    if (grade == null) {
      filteredGrade = Static.timetable.data.grade;
      myUnparsed..addAll(unparsed[filteredGrade])..addAll(unparsed['other']);
      return null;
    }
    return [...unparsed[grade]..addAll(unparsed['other'])];
  }

  /// Set the filtered lists
  void filterSubstitutions() {
    myChanges = [];
    otherChanges = [];
    undefinedChanges = [];

    final List<TimetableSubject> selectedSubjects =
        Static.timetable.data.getAllSelectedSubjects();
    final List<String> selectedIds = selectedSubjects.map((s) => s.id).toList();
    final List<String> selectedCourseIds =
        selectedSubjects.map((s) => s.courseID).toList();

    filteredGrade = Static.timetable.data.grade;
    for (final substitution in data[filteredGrade]) {
      if (substitution.id == null && substitution.courseID == null) {
        undefinedChanges.add(substitution);
      } else if ((substitution.id != null &&
              selectedIds.contains(substitution.id)) ||
          (substitution.courseID != null &&
              selectedCourseIds.contains(substitution.courseID))) {
        // If it is no exam, add to my changes
        if (!substitution.isExam) {
          myChanges.add(substitution);
        } else if (selectedSubjects[
                selectedCourseIds.indexOf(substitution.courseID)]
            .writeExams) {
          myChanges.add(substitution);
        } else {
          otherChanges.add(substitution);
        }
      } else {
        otherChanges.add(substitution);
      }
    }
  }

  /// Check if a substitution if for the user
  bool isMySubstitution(Substitution substitution) =>
      myChanges.contains(substitution);
}

/// Describes a substitution of a substitution plan day...
class Substitution {
  // ignore: public_member_api_docs
  Substitution(
      {@required this.unit,
      @required this.type,
      @required this.info,
      @required this.id,
      @required this.courseID,
      @required this.original,
      @required this.changed});

  /// Creates a substitution from json map
  factory Substitution.fromJson(Map<String, dynamic> json) => Substitution(
        unit: json['unit'],
        type: json['type'],
        info: json['info'],
        id: json['id'],
        courseID: json['courseID'],
        original: SubstitutionDetails.fromJson(json['original']),
        changed: SubstitutionDetails.fromJson(json['changed']),
      );

  /// starts with 0; 6. unit is the lunch break
  final int unit;

  /// 0 => substitution; 1 => free lesson; 2 => exam
  final int type;

  /// The raw substitution information
  final String info;

  /// The timetable id
  final String id;

  /// The timetable courseID
  final String courseID;

  /// The original subject details
  final SubstitutionDetails original;

  /// The changed subject details
  final SubstitutionDetails changed;

  /// Returns the color of the substitution
  Color get color => type == 0 ? Colors.orange : type == 1 ? null : Colors.red;

  /// Check if it is an exam
  bool get isExam => type == 2;

  /// Check if the substitution could be filtered
  bool get sure => id != null && courseID != null;

  /// Returns the timetable unit for this substitution
  TimetableUnit get timetableUnit {
    if (id != null) {
      final fragments = id.split('-').sublist(2, 5).map(int.parse).toList();
      return Static.timetable.data.days[fragments[0]].units[fragments[1]];
    }
    return null;
  }

  /// Compares this substitution to the given substitution
  bool equals(Substitution c) =>
      unit == c.unit &&
      type == c.type &&
      courseID == c.courseID &&
      info == c.info &&
      id == c.id;
}

/// Describes details of a substitution...
class SubstitutionDetails {
  // ignore: public_member_api_docs
  SubstitutionDetails({
    @required this.teacherID,
    @required this.roomID,
    @required this.subjectID,
  });

  /// Creates a substitution details from json
  factory SubstitutionDetails.fromJson(Map<String, dynamic> json) =>
      SubstitutionDetails(
        teacherID: json['teacherID'].replaceAll('+', '\n'),
        roomID: json['roomID'],
        subjectID: json['subjectID'],
      );

  // ignore: public_member_api_docs
  final String teacherID;
  // ignore: public_member_api_docs
  final String roomID;
  // ignore: public_member_api_docs
  final String subjectID;

  /// Compares to substitution details
  bool equals(SubstitutionDetails c) =>
      teacherID == c.teacherID &&
      roomID == c.roomID &&
      subjectID == c.subjectID;
}
