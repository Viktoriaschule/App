import 'package:flutter/material.dart';
import 'package:viktoriaapp/calendar/calendar_event_dialog.dart';
import 'package:viktoriaapp/models/models.dart';
import 'package:viktoriaapp/utils/static.dart';
import 'package:viktoriaapp/utils/theme.dart';

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
    final yesterday = DateTime.now().add(Duration(days: -1));
    return widget.date.year == yesterday.year &&
        widget.date.month == yesterday.month &&
        widget.date.day == yesterday.day;
  }

  bool _isYesterdayInSameWeekAsToday() {
    final today = DateTime.now();
    final yesterday = DateTime.now().add(Duration(days: -1));
    return weekNumber(today) == weekNumber(yesterday);
  }

  bool _isTodayOneWeekAgo() {
    final today = DateTime.now();
    return weekNumber(today) == weekNumber(widget.date) + 1 &&
        today.weekday == widget.date.weekday;
  }

  bool _isWeekend() => widget.date.weekday > 5;

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
            color: _isToday() ? Colors.blue.shade100 : null,
            border: Border(
              right: BorderSide(
                color: _isToday() ||
                        (_isYesterday() && _isYesterdayInSameWeekAsToday())
                    ? Colors.blue.shade500
                    : textColor(context).withOpacity(0.5),
              ),
              bottom: BorderSide(
                color: _isToday() || _isTodayOneWeekAgo()
                    ? Colors.blue.shade500
                    : textColor(context).withOpacity(0.5),
              ),
            ),
          ),
          child: Text(
            widget.date.day.toString(),
            style: TextStyle(
              color: _isWeekend()
                  ? MediaQuery.of(context).platformBrightness ==
                          Brightness.light
                      ? Colors.red
                      : Colors.red.withOpacity(0.5)
                  : !widget.main
                      ? textColor(context).withOpacity(0.5)
                      : _isToday() ? Colors.blue : textColor(context),
              fontWeight: widget.main ? FontWeight.bold : null,
            ),
          ),
        ),
      );
}
