import 'package:flutter/material.dart';
import 'package:ginko/calendar/calendar_row.dart';
import 'package:ginko/utils/custom_button.dart';
import 'package:ginko/utils/dialog_content_wrapper.dart';
import 'package:ginko/utils/theme.dart';
import 'package:ginko/models/models.dart';

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
            color: textColor(context),
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
                  'Ok',
                  style: TextStyle(color: darkColor),
                ),
              ),
            ],
          ),
        ],
      );
}
