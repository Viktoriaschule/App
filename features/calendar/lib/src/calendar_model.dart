// Describes a list of calendar events...
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// All school events
class Calendar {
  // ignore: public_member_api_docs
  Calendar({@required this.years, @required this.events});

  /// Cerates the calendar from json map
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

  /// Returns all events since the given data
  List<CalendarEvent> getEventsSince(DateTime start) =>
      getEventsForTimeSpan(start, null);

  /// Get all events that overlap with a certain time span
  List<CalendarEvent> getEventsForTimeSpan(DateTime start, DateTime end) =>
      events.where((event) {
        if (event.start == start) {
          return true;
        }
        if (end != null && event.end == end) {
          return true;
        }
        if (event.start.isBefore(start) &&
            (end == null || event.end.isAfter(end))) {
          return true;
        }
        if (event.start.isAfter(start) &&
            (end == null || event.end.isBefore(end))) {
          return true;
        }
        if (event.start.isAfter(start) &&
            (end == null || event.start.isBefore(end))) {
          return true;
        }
        if (event.end.isAfter(start) &&
            (end == null || event.end.isBefore(end))) {
          return true;
        }
        return false;
      }).toList();
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
    if (start.hour != 0 || start.minute != 0) {
      dateStr = _dateTimeFormat.format(start);
    } else {
      dateStr = _dateFormat.format(start);
    }
    if (DateTime(
          start.year,
          start.month,
          start.day,
        ).add(Duration(days: 1)).subtract(Duration(seconds: 1)) !=
        end) {
      dateStr += ' - ';
      if (end.hour != 0 || end.minute != 0) {
        dateStr += _dateTimeFormat.format(end);
      } else {
        dateStr += _dateFormat.format(end);
      }
    }
    return dateStr;
  }
}
