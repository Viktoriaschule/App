import 'package:calendar/calendar.dart';
import 'package:flutter/material.dart';
import 'package:utils/utils.dart';

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
          child: Card(
            margin: EdgeInsets.all(0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(1.5),
              ),
            ),
            color: Theme.of(context).accentColor,
            child: Padding(
              padding: const EdgeInsets.all(3),
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
        ),
      );
}
