import 'package:calendar/src/calendar_keys.dart';
import 'package:utils/utils.dart';

import 'calendar_events.dart';
import 'calendar_model.dart';

/// CalendarLoader class
class CalendarLoader extends Loader<Calendar> {
  // ignore: public_member_api_docs
  CalendarLoader() : super(CalendarKeys.calendar, CalendarUpdateEvent());

  @override
  // ignore: type_annotate_public_apis, always_declare_return_types
  fromJSON(json) => Calendar.fromJson(json);
}
