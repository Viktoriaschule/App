import 'package:flutter/material.dart';
import 'package:viktoriaapp/calendar/calendar_event_dialog.dart';
import 'package:viktoriaapp/utils/theme.dart';
import 'package:viktoriaapp/models/models.dart';

// ignore: public_member_api_docs
class CalendarGridEvent extends StatelessWidget {
  // ignore: public_member_api_docs
  const CalendarGridEvent({
    this.event,
  });

  // ignore: public_member_api_docs
  final CalendarEvent event;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: () {
          showDialog(
            context: context,
            builder: (context) => CalendarEventDialog(
              events: [event],
            ),
          );
        },
        child: Material(
          elevation: 1,
          child: Container(
            padding: EdgeInsets.all(2.5),
            decoration: BoxDecoration(
              color: Colors.green.shade100,
              border: Border.all(color: Colors.green.shade500),
            ),
            child: Text(
              event.name,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: TextStyle(
                fontSize: 12,
                color: darkColor,
              ),
            ),
          ),
        ),
      );
}
