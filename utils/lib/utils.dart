library utils;

import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:utils/src/localizations.dart';

export 'src/crypt.dart';
export 'src/events.dart';
export 'src/feature_utils/feature.dart';
export 'src/info_card_utils.dart';
export 'src/keys.dart';
export 'src/loader.dart';
export 'src/localizations.dart';
export 'src/pages.dart';
export 'src/plugins/firebase/firebase.dart';
export 'src/plugins/platform/platform.dart';
export 'src/plugins/pwa/pwa.dart';
export 'src/plugins/storage/storage.dart';
export 'src/screen_sizes.dart';
export 'src/static.dart';
export 'src/tags_loader.dart';
export 'src/tags_model.dart';
export 'src/theme.dart';
export 'src/times.dart';
export 'src/updates.dart';
export 'src/updates_model.dart';
export 'src/user_model.dart';

// ignore: public_member_api_docs
const String viktoriaAppBaseURL = 'https://viktoriaapp.fingeg.de';

/// Http status codes
enum StatusCode {
  // ignore: public_member_api_docs
  success,
  // ignore: public_member_api_docs
  unauthorized,
  // ignore: public_member_api_docs
  offline,
  // ignore: public_member_api_docs
  failed,
  // ignore: public_member_api_docs
  wrongFormat,
}

/// Reduces multiple status codes to one
StatusCode reduceStatusCodes(List<StatusCode> statusCodes) {
  if (statusCodes.isEmpty) {
    return StatusCode.success;
  }
  if (statusCodes
      .map((e) => e == StatusCode.success)
      .reduce((v1, v2) => v1 && v2)) {
    return StatusCode.success;
  } else if (statusCodes.contains(StatusCode.offline)) {
    return StatusCode.offline;
  } else if (statusCodes.contains(StatusCode.wrongFormat)) {
    return StatusCode.wrongFormat;
  }
  return StatusCode.failed;
}

/// Returns the status msg for the user
String getStatusCodeMsg(StatusCode status) {
  switch (status) {
    case StatusCode.offline:
      return AppLocalizations.youAreOffline;
    case StatusCode.failed:
      return AppLocalizations.connectingToServerFailed;
    case StatusCode.wrongFormat:
      return AppLocalizations.serverError;
    case StatusCode.unauthorized:
      return AppLocalizations.credentialsWrong;
    case StatusCode.success:
      return AppLocalizations.success;
  }
  return null;
}

// ignore: public_member_api_docs
StatusCode getStatusCode(int httpStatusCode) {
  switch (httpStatusCode) {
    case 401:
      return StatusCode.unauthorized;
    case 200:
      return StatusCode.success;
    default:
      return StatusCode.failed;
  }
}

/// List of all grades
List<String> grades = [
  '5a',
  '5b',
  '5c',
  '6a',
  '6b',
  '6c',
  '7a',
  '7b',
  '7c',
  '8a',
  '8b',
  '8c',
  '9a',
  '9b',
  '9c',
  'ef',
  'q1',
  'q2',
];

/// Check if a grade is a senior grade
bool isSeniorGrade(String grade) => grades.indexOf(grade) > 14;

/// List of all weekdays
Map<int, String> weekdays = {
  0: 'Montag',
  1: 'Dienstag',
  2: 'Mittwoch',
  3: 'Donnerstag',
  4: 'Freitag',
  5: 'Samstag',
  6: 'Sonntag',
};

/// List of all months
Map<int, String> months = {
  0: 'Januar',
  1: 'Februar',
  2: 'März',
  3: 'April',
  4: 'Main',
  5: 'Juni',
  6: 'Juli',
  7: 'August',
  8: 'September',
  9: 'Oktober',
  10: 'November',
  11: 'Dezember',
};

/// The date format to display all dates in
DateFormat outputDateFormat = DateFormat('dd.MM.y');

/// The short date format to display all dates in
DateFormat shortOutputDateFormat = DateFormat('dd.MM');

/// The date and time format to display all dates and times in
DateFormat outputDateTimeFormat = DateFormat('dd.MM.y HH:mm');

var _dateFormats = [];

/// Setup all date formats used by the web server
Future setupDateFormats() async {
  await initializeDateFormatting('de', null);
  _dateFormats = [
    DateFormat.yMMMMd('de'),
    outputDateFormat,
  ];
}

/// Parse a date using any format used by the server
DateTime parseDate(String date) {
  for (final format in _dateFormats.cast<DateFormat>()) {
    try {
      try {
        if (format.parse(date).year < 2000) {
          date =
              '${date.split('.')[0]}.${date.split('.')[1]}.${(int.parse(date.split('.')[2]) + 2000).toString()}';
        }
        // ignore: empty_catches
      } on Exception {}

      return format.parse(date);
      // ignore: avoid_catches_without_on_clauses, empty_catches
    } catch (e) {}
  }
  throw FormatException('$date was not matching any date formats');
}

/// Get the week number of a year by date
int weekNumber(DateTime date) {
  final dayOfYear = int.parse(DateFormat('D').format(date));
  return ((dayOfYear - date.weekday + 10) / 7).floor();
}

/// Get the Monday of the week
/// Skips to next week when weekend
DateTime monday(DateTime date) {
  var newDate = date.subtract(Duration(
    days: date.weekday - 1,
    hours: date.hour,
    minutes: date.minute,
    seconds: date.second,
    milliseconds: date.millisecond,
    microseconds: date.microsecond,
  ));
  newDate = newDate.add(Duration(days: date.weekday > 5 ? 7 : 0));
  // Daylight saving time lol
  if (newDate.hour == 23) {
    newDate = newDate.add(Duration(hours: 1));
  }
  return newDate;
}
