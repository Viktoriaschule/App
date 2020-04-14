// Describes a list of calendar events...
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// All school events
class Calendar {
  // ignore: public_member_api_docs
  Calendar({@required this.years, @required this.events});

  /// Creates the calendar from json map
  factory Calendar.fromJson(Map<String, dynamic> json) => Calendar(
      years: json['years'].cast<int>().toList(),
      events: json['data']
          .map((json) => CalendarEvent.fromJson(json))
          .cast<CalendarEvent>()
          .toList());

  /// The years of the event
  final List<int> years;

  /// All events
  final List<CalendarEvent> events;

  /// Returns all events since the given date
  List<CalendarEvent> getEventsSince(DateTime start) => events
      .where((event) => event.start == start || event.start.isAfter(start))
      .toList()
        ..sort((e1, e2) => e1.start.compareTo(e2.start));

  /// Returns all events for a specific date
  List<CalendarEvent> getEventsForDate(DateTime date) => getEventsSince(date)
      .where((event) => event.start
          .isBefore(date.add(Duration(days: 1)).subtract(Duration(seconds: 1))))
      .toList();
}

/// Describes a calendar event...
class CalendarEvent {
  // ignore: public_member_api_docs
  CalendarEvent({this.name, this.info, DateTime start, DateTime end}) {
    this.start = start ?? end;
    this.end = end ?? start;
  }

  /// Creates calendar event from json map
  factory CalendarEvent.fromJson(Map<String, dynamic> json) => CalendarEvent(
        name: json['name'],
        info: json['info'],
        start: json['start'] != null
            ? DateTime.parse(json['start']).toLocal()
            : null,
        end: json['end'] != null ? DateTime.parse(json['end']).toLocal() : null,
      );

  // ignore: public_member_api_docs
  String name;

  // ignore: public_member_api_docs
  String info;

  // ignore: public_member_api_docs
  DateTime start;

  // ignore: public_member_api_docs
  DateTime end;

  /// Get the date string of the event
  String get dateString {
    final _dateFormat = DateFormat.yMMMMd('de');
    final _dateTimeFormat = DateFormat.yMMMMd('de').add_Hm();
    var dateStr = '';
    // Show start time if the time is not 00:00
    if (start.hour != 0 || start.minute != 0) {
      dateStr = _dateTimeFormat.format(start);
    } else {
      dateStr = _dateFormat.format(start);
    }

    // Show the end date if it is not 00:00 on the same day
    if (end.hour != 0 || end.minute != 0 || end.day != start.day) {
      // Show a time if it is not 00:000
      if (end.hour != 0 || end.minute != 0) {
        dateStr += ' - ';
        dateStr += _dateTimeFormat.format(end);
      }
      // Show a day span without double month and year
      else if (start.month == end.month && start.year == end.year) {
        final dString = dateStr.split(' ')..insert(1, ' - ${end.day}.');
        dateStr = dString.join(' ');
      }
      // Show the whole end date
      else {
        dateStr += ' - ';
        dateStr += _dateFormat.format(end);
      }
    }
    return dateStr;
  }
}
