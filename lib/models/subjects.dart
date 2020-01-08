// ignore: public_member_api_docs
class Subjects {
  // ignore: public_member_api_docs
  Subjects({this.subjects});

  // ignore: public_member_api_docs
  final Map<String, String> subjects;

  /// Returns the full subject name of a subject id
  String getSubject(String subjectID) => subjects[subjectID] ?? subjectID;
}
