// ignore: public_member_api_docs
import 'package:flutter/material.dart';

// ignore: public_member_api_docs
class Subjects {
  // ignore: public_member_api_docs
  Subjects({
    @required this.subjects,
  });

  // ignore: public_member_api_docs
  factory Subjects.fromJSON(Map<String, dynamic> json) => Subjects(
        subjects: json
            .cast<String, String>()
            .map((key, value) => MapEntry<String, String>(key, value)),
      );

  // ignore: public_member_api_docs
  final Map<String, String> subjects;

  /// Returns the full subject name of a subject id
  String getSubject(String subjectID) => subjects[subjectID] ?? subjectID;
}
