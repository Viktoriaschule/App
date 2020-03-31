import 'package:timetable/timetable.dart';
import 'package:utils/utils.dart';

/// TimetableLoader class
class TimetableLoader extends Loader<Timetable> {
  // ignore: public_member_api_docs
  TimetableLoader() : super(TimetableKeys.timetable, TimetableUpdateEvent());

  @override
  // ignore: type_annotate_public_apis, always_declare_return_types
  fromJSON(json) => Timetable.fromJSON(json);
}
