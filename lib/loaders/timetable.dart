import 'package:viktoriaapp/loaders/loader.dart';
import 'package:viktoriaapp/models/models.dart';
import 'package:viktoriaapp/utils/events.dart';

/// TimetableLoader class
class TimetableLoader extends Loader<Timetable> {
  // ignore: public_member_api_docs
  TimetableLoader() : super(Keys.timetable, TimetableUpdateEvent());

  @override
  // ignore: type_annotate_public_apis, always_declare_return_types
  fromJSON(json) => Timetable.fromJSON(json);
}
