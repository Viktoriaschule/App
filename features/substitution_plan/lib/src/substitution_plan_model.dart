import 'package:flutter/material.dart';
import 'package:timetable/timetable.dart';
import 'package:utils/utils.dart';

/// Describes the substitution plan
class SubstitutionPlan {
  // ignore: public_member_api_docs
  SubstitutionPlan({@required this.days});

  // ignore: public_member_api_docs
  factory SubstitutionPlan.fromJSON(List<dynamic> json) => SubstitutionPlan(
        days: json
            .map<SubstitutionPlanDay>(
                (day) => SubstitutionPlanDay.fromJson(day))
            .toList()
              ..sort((d1, d2) => d1.date.compareTo(d2.date)),
      );

  /// All substitution plan days
  final List<SubstitutionPlanDay> days;

  /// Sync the substitution plan with the given timetable
  void syncWithTimetable(Timetable timetable) {
    for (final day in days) {
      day.syncWithTimetable(timetable);
    }
  }

  /// Updates the substitution plan filter
  void updateFilter(Timetable timetable) {
    for (final day in days) {
      day.filterSubstitutions(timetable);
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
  List<Substitution> myChanges = [];

  /// The undefined filtered substitutions
  List<Substitution> undefinedChanges = [];

  /// The other filtered substitutions
  List<Substitution> otherChanges = [];

  /// The filtered unparsed substitutions
  List<String> myUnparsed = [];

  /// The current user grade
  String filteredGroup;

  /// Synchronize the substitution plan with the given timetable
  void syncWithTimetable(Timetable timetable) {
    filterSubstitutions(timetable);
    filterUnparsed(timetable);
  }

  /// Sorts all substitutions by the unit, courseID and type
  void sort() {
    data.forEach((group, substitutions) {
      substitutions.sort((a, b) {
        var r = a.unit.compareTo(b.unit);
        if (r == 0) {
          r = a.courseID.compareTo(b.courseID);
        }
        if (r == 0) {
          r = b.type.compareTo(a.type);
        }
        return r;
      });
    });
  }

  /// Set the unparsed filtered lists
  List<String> filterUnparsed(Timetable timetable, {String group}) {
    myUnparsed = [];
    if (group == null) {
      filteredGroup = timetable.group;
      myUnparsed
        ..addAll(unparsed[filteredGroup] ?? [])
        ..addAll(unparsed['other'] ?? []);
      return null;
    }
    return [...unparsed[group]..addAll(unparsed['other'])];
  }

  /// Set the filtered lists
  void filterSubstitutions(Timetable timetable) {
    myChanges = [];
    otherChanges = [];
    undefinedChanges = [];

    final List<TimetableSubject> selectedSubjects =
    timetable.getAllSelectedSubjects();
    final List<String> selectedIds = selectedSubjects.map((s) => s.id).toList();
    final List<String> selectedCourseIds =
    selectedSubjects.map((s) => s.courseID).toList();

    filteredGroup = timetable.group;
    for (final substitution in data[filteredGroup]) {
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
  Substitution({
    @required this.unit,
    @required this.type,
    @required this.info,
    @required this.id,
    @required this.courseID,
    @required this.original,
    @required this.changed,
    @required this.description,
  });

  /// Creates a substitution from json map
  factory Substitution.fromJson(Map<String, dynamic> json) => Substitution(
        unit: json['unit'],
        type: json['type'],
        info: json['info'],
        id: json['id'],
        courseID: json['courseID'],
        description: json['description'],
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

  /// A specific substitution case description
  final String description;

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
  TimetableUnit getTimetableUnit(Timetable timetable) {
    if (id != null) {
      final fragments = id.split('-').sublist(2, 5).map(int.parse).toList();
      return timetable.days[fragments[0]].units[fragments[1]];
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
    @required this.participantID,
    @required this.roomID,
    @required this.subjectID,
  });

  /// Creates a substitution details from json
  factory SubstitutionDetails.fromJson(Map<String, dynamic> json) =>
      SubstitutionDetails(
        participantID: optimizeParticipantID(json['participantID']),
        roomID: json['roomID'],
        subjectID: json['subjectID'],
      );

  /// The participant identifier
  ///
  /// For students the teacher and
  /// for teachers the grade
  final String participantID;

  // ignore: public_member_api_docs
  final String roomID;

  // ignore: public_member_api_docs
  final String subjectID;

  /// Compares to substitution details
  bool equals(SubstitutionDetails c) =>
      participantID == c.participantID &&
          roomID == c.roomID &&
          subjectID == c.subjectID;
}
