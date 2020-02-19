import 'package:viktoriaapp/loaders/loader.dart';
import 'package:viktoriaapp/models/models.dart';

/// CalendarLoader class
class CalendarLoader extends Loader<Calendar> {
  // ignore: public_member_api_docs
  CalendarLoader() : super(Keys.calendar);

  @override
  // ignore: type_annotate_public_apis, always_declare_return_types
  fromJSON(json) => Calendar.fromJson(json);
}
