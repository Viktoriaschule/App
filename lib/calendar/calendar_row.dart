import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:after_layout/after_layout.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:viktoriaapp/models/models.dart';
import 'package:viktoriaapp/plugins/platform/platform.dart';
import 'package:viktoriaapp/utils/theme.dart';
import 'package:viktoriaapp/widgets/custom_row.dart';

// ignore: public_member_api_docs
class CalendarRow extends StatefulWidget {
  // ignore: public_member_api_docs
  const CalendarRow({
    @required this.event,
    this.showDate = false,
    this.showSplit = true,
  });

  // ignore: public_member_api_docs
  final CalendarEvent event;

  // ignore: public_member_api_docs
  final bool showDate;

  // ignore: public_member_api_docs
  final bool showSplit;

  @override
  _CalendarRowState createState() => _CalendarRowState();
}

class _CalendarRowState extends State<CalendarRow>
    with AfterLayoutMixin<CalendarRow> {
  bool _initialized = false;

  @override
  Future afterFirstLayout(BuildContext context) async {
    await initializeDateFormatting('de', null);
    setState(() {
      _initialized = true;
    });
  }

  @override
  Widget build(BuildContext context) => !_initialized
      ? Container()
      : CustomRow(
          showSplit: widget.showSplit,
          leading: Icon(
            Icons.calendar_today,
            color: ThemeWidget.of(context).textColorLight,
          ),
          title: '${widget.event.name}',
          titleOverflow: TextOverflow.visible,
          subtitle: Text(
            widget.event.dateString,
            style: TextStyle(
                color: ThemeWidget.of(context).textColor,
                fontWeight: FontWeight.w100),
          ),
          last: Platform().isMobile
              ? IconButton(
                  onPressed: () {
                    final startDate = widget.event.start.subtract(Duration(
                      hours: widget.event.start.hour,
                      minutes: widget.event.start.minute,
                      seconds: widget.event.start.second,
                    ));
                    final endDate = widget.event.end.subtract(Duration(
                      hours: widget.event.end.hour,
                      minutes: widget.event.end.minute,
                      seconds: widget.event.end.second,
                    ));
                    Add2Calendar.addEvent2Cal(Event(
                      title: widget.event.name,
                      description: widget.event.info,
                      startDate: widget.event.start,
                      endDate: widget.event.end,
                      allDay: startDate != endDate,
                    ));
                  },
                  icon: Icon(
                    Icons.add,
                    color: ThemeWidget.of(context).textColorLight,
                  ),
                )
              : null,
        );
}
