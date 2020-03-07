import 'package:utils/utils.dart';

/// All keys for the timetable feature
class TimetableKeys extends FeatureKeys {
  // ignore: public_member_api_docs
  static const timetable = 'timetable';

  // ignore: public_member_api_docs
  static String selection(String block) => 'selection-$block';

  // ignore: public_member_api_docs
  static String exam(String block) => 'exam-$block';

  // ignore: public_member_api_docs
  static String selectionTimestamp(String block) =>
      'timestamp-selection-$block';

  // ignore: public_member_api_docs
  static String examTimestamp(String block) => 'timestamp-exam-$block';
}
