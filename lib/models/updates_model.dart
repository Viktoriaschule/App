import 'package:flutter/material.dart';

/// Defines all updates
class Updates {
  // ignore: public_member_api_docs
  Updates(
      {@required this.timetable,
      @required this.substitutionPlan,
      @required this.cafetoria,
      @required this.calendar,
      @required this.workgroups,
      @required this.aixformation,
      @required this.minAppLevel,
      @required this.subjects,
      @required this.grade});

  /// Creates updates from json map
  factory Updates.fromJson(Map<String, dynamic> json) => Updates(
        timetable: json['timetable'],
        substitutionPlan: json['substitutionPlan'],
        cafetoria: json['cafetoria'],
        calendar: json['calendar'],
        workgroups: json['workgroups'],
        aixformation: json['aixformation'],
        minAppLevel: json['minAppLevel'],
        subjects: json['subjects'],
        grade: json['grade'],
      );

  // ignore: public_member_api_docs
  String timetable;
  // ignore: public_member_api_docs
  String substitutionPlan;
  // ignore: public_member_api_docs
  String cafetoria;
  // ignore: public_member_api_docs
  String calendar;
  // ignore: public_member_api_docs
  String workgroups;
  // ignore: public_member_api_docs
  String subjects;
  // ignore: public_member_api_docs
  final int minAppLevel;
  // ignore: public_member_api_docs
  String aixformation;
  // ignore: public_member_api_docs
  String grade;
}
