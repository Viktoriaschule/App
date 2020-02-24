import 'package:flutter/material.dart';
import 'package:viktoriaapp/calendar/calendar_row.dart';
import 'package:viktoriaapp/widgets/custom_button.dart';
import 'package:viktoriaapp/widgets/dialog_content_wrapper.dart';
import 'package:viktoriaapp/utils/theme.dart';
import 'package:viktoriaapp/models/models.dart';

// ignore: public_member_api_docs
class CalendarEventDialog extends StatelessWidget {
  // ignore: public_member_api_docs
  const CalendarEventDialog({
    @required this.events,
    this.date,
    Key key,
  }) : super(key: key);

  // ignore: public_member_api_docs
  final List<CalendarEvent> events;

  // ignore: public_member_api_docs
  final DateTime date;

  @override
  Widget build(BuildContext context) => SimpleDialog(
        contentPadding: EdgeInsets.only(left: 5, right: 5, top: 10),
        title: Text(
          date == null ? 'Termin' : outputDateFormat.format(date),
          style: TextStyle(
            color: ThemeWidget.of(context).textColor(),
          ),
        ),
        children: [
          DialogContentWrapper(
            children: [
              ...events
                  .map((event) => CalendarRow(
                        event: event,
                      ))
                  .toList(),
              CustomButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  'OK',
                  style: TextStyle(color: darkColor),
                ),
              ),
            ],
          ),
        ],
      );
}
