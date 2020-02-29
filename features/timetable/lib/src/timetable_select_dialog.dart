import 'package:flutter/material.dart';
import 'package:utils/utils.dart';
import 'package:widgets/widgets.dart';

import 'timetable_model.dart';
import 'timetable_row.dart';

// ignore: public_member_api_docs
class TimetableSelectDialog extends StatelessWidget {
  // ignore: public_member_api_docs
  const TimetableSelectDialog({
    @required this.weekday,
    @required this.unit,
    Key key,
  }) : super(key: key);

  // ignore: public_member_api_docs
  final int weekday;

  // ignore: public_member_api_docs
  final TimetableUnit unit;

  @override
  Widget build(BuildContext context) => SimpleDialog(
        title: Text(
          '${weekdays[weekday]} ${unit.unit + 1}.',
          style: TextStyle(
            color: ThemeWidget.of(context).textColor,
          ),
        ),
        children: [
          DialogContentWrapper(
            children: unit.subjects
                .map((subject) => InkWell(
                      onTap: () {
                        Navigator.of(context).pop(subject);
                      },
                      child: Container(
                        margin: EdgeInsets.only(
                          top: 10,
                          bottom: 10,
                        ),
                        child: TimetableRow(
                          showUnit: false,
                          showSplit: false,
                          subject: subject,
                        ),
                      ),
                    ))
                .toList()
                .cast<Widget>(),
          ),
        ],
      );
}
