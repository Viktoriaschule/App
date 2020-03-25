import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:calendar/calendar.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:utils/utils.dart';
import 'package:widgets/widgets.dart';

// ignore: public_member_api_docs
class CalendarRow extends PreferredSize {
  // ignore: public_member_api_docs
  const CalendarRow({
    @required this.event,
    this.showDate = false,
    this.showSplit = true,
    this.showAddButton = true,
  });

  // ignore: public_member_api_docs
  final CalendarEvent event;

  // ignore: public_member_api_docs
  final bool showDate;

  // ignore: public_member_api_docs
  final bool showSplit;

  // ignore: public_member_api_docs
  final bool showAddButton;

  @override
  Size get preferredSize => Size.fromHeight(customRowHeight);

  @override
  Widget build(BuildContext context) => CustomRow(
        showSplit: showSplit,
        leading: Icon(
          Icons.calendar_today,
          color: ThemeWidget.of(context).textColorLight,
        ),
        title: '${event.name}',
        titleOverflow: TextOverflow.visible,
        subtitle: Text(
          event.dateString,
          style: TextStyle(
              color: ThemeWidget.of(context).textColor,
              fontWeight: FontWeight.w100),
        ),
        last: Platform().isMobile && showAddButton
            ? IconButton(
                onPressed: () {
                  final startDate = event.start.subtract(Duration(
                    hours: event.start.hour,
                    minutes: event.start.minute,
                    seconds: event.start.second,
                  ));
                  final endDate = event.end.subtract(Duration(
                    hours: event.end.hour,
                    minutes: event.end.minute,
                    seconds: event.end.second,
                  ));
                  Add2Calendar.addEvent2Cal(Event(
                    title: event.name,
                    description: event.info,
                    startDate: event.start,
                    endDate: event.end,
                    allDay: startDate != endDate,
                  ));
                },
                icon: Icon(
                  MdiIcons.playlistPlus,
                  color: ThemeWidget.of(context).textColorLight,
                ),
              )
            : null,
      );
}
