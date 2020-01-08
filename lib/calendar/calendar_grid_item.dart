import 'package:flutter/material.dart';
import 'package:ginko/calendar/calendar_event_dialog.dart';
import 'package:ginko/utils/static.dart';

// ignore: public_member_api_docs
class CalendarGridItem extends StatefulWidget {
  // ignore: public_member_api_docs
  const CalendarGridItem({
    @required this.date,
    @required this.main,
  }) : super();

  // ignore: public_member_api_docs
  final DateTime date;

  // ignore: public_member_api_docs
  final bool main;

  @override
  _CalendarGridItemState createState() => _CalendarGridItemState();
}

class _CalendarGridItemState extends State<CalendarGridItem> {
  bool _isToday() {
    final today = DateTime.now();
    return widget.date.year == today.year &&
        widget.date.month == today.month &&
        widget.date.day == today.day;
  }

  bool _isYesterday() {
    final today = DateTime.now().add(Duration(days: -1));
    return widget.date.year == today.year &&
        widget.date.month == today.month &&
        widget.date.day == today.day;
  }

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: () {
          final events = Static.calendar.data.getEventsForTimeSpan(
              widget.date,
              widget.date
                  .add(Duration(days: 1))
                  .subtract(Duration(seconds: 1)));
          if (events.isNotEmpty) {
            showDialog(
              context: context,
              builder: (context) => CalendarEventDialog(
                events: events,
                date: widget.date,
              ),
            );
          }
        },
        child: Container(
          padding: EdgeInsets.all(2.5),
          decoration: BoxDecoration(
            color: _isToday()
                ? Colors.blue.shade100
                : widget.main ? null : Colors.grey.shade100,
            border: Border(
              right: BorderSide(
                color: _isToday() || _isYesterday()
                    ? Colors.blue.shade500
                    : Colors.grey.shade500,
              ),
              bottom: BorderSide(
                color:
                    !_isToday() ? Colors.grey.shade500 : Colors.blue.shade500,
              ),
            ),
          ),
          child: Text(
            widget.date.day.toString(),
            style: TextStyle(
              color: !widget.main
                  ? Colors.grey.shade400
                  : _isToday() ? Colors.blue : Colors.black,
              fontWeight: widget.main ? FontWeight.bold : null,
            ),
          ),
        ),
      );
}
