import 'package:ginko/loaders/loader.dart';
import 'package:ginko/models/models.dart';

/// TimetableLoader class
class TimetableLoader extends Loader<Timetable> {
  // ignore: public_member_api_docs
  TimetableLoader() : super(Keys.timetable);

  @override
  // ignore: type_annotate_public_apis, always_declare_return_types
  fromJSON(json) => Timetable.fromJSON(json);
}
