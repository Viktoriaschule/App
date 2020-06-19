import 'package:flutter/cupertino.dart';
import 'package:timetable/timetable.dart';
import 'package:utils/utils.dart';

/// TimetableLoader class
class TimetableLoader extends Loader<Timetable> {
  // ignore: public_member_api_docs
  TimetableLoader() : super(TimetableKeys.timetable, TimetableUpdateEvent());

  @override
  // ignore: type_annotate_public_apis, always_declare_return_types
  fromJSON(json) => Timetable.fromJSON(json);

  /// Loads another timetable in addition to the current one
  Future<Timetable> loadOtherTimetable(
    BuildContext context,
    String group, {
    bool online = true,
  }) async {
    LoaderResponse<Timetable> result;
    if (online) {
      result = await fetch(context, path: '$key/$group');
    }

    if (!online || result.statusCode != StatusCode.success) {
      final rawJson = Static.storage.getString('$key-$group');
      return rawJson == null ? null : tryParseJSON(rawJson).data;
    }

    Static.storage.setString('$key-$group', result.rawData);
    return result.data;
  }
}
