import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:ginko/utils/custom_row.dart';
import 'package:ginko/utils/static.dart';
import 'package:ginko/models/models.dart';

// ignore: public_member_api_docs
class TimetableRow extends StatelessWidget {
  // ignore: public_member_api_docs
  const TimetableRow({
    @required this.subject,
    this.showUnit = true,
    this.showSplit = true,
    Key key,
  })  : assert(subject != null, 'subject must not be null'),
        super(key: key);

  // ignore: public_member_api_docs
  final TimetableSubject subject;

  // ignore: public_member_api_docs
  final bool showUnit;

  // ignore: public_member_api_docs
  final bool showSplit;

  @override
  Widget build(BuildContext context) {
    final unit = subject.unit;
    final times = Times.getUnitTimes(unit, false);
    final startHour = (times[0].inHours.toString().length == 1 ? '0' : '') +
        times[0].inHours.toString();
    final startMinute =
        ((times[0].inMinutes % 60).toString().length == 1 ? '0' : '') +
            (times[0].inMinutes % 60).toString();
    final endHour = (times[1].inHours.toString().length == 1 ? '0' : '') +
        times[1].inHours.toString();
    final endMinute =
        ((times[1].inMinutes % 60).toString().length == 1 ? '0' : '') +
            (times[1].inMinutes % 60).toString();
    final timeStr = '$startHour:$startMinute - $endHour:$endMinute';
    return CustomRow(
      splitColor: Colors.transparent,
      showSplit: !(subject.subjectID == 'Mittagspause' ||
              subject.subjectID == 'none') &&
          showSplit,
      leading: showUnit && unit != 5
          ? Align(
              alignment: Alignment(0.3, 0),
              child: Text(
                (unit + 1).toString(),
                style: TextStyle(
                  fontSize: 25,
                  color: Colors.black54,
                  fontWeight: FontWeight.w100,
                ),
              ),
            )
          : null,
      titleAlignment:
          subject.subjectID == 'Mittagspause' || subject.subjectID == 'none'
              ? CrossAxisAlignment.center
              : CrossAxisAlignment.start,
      title: Static.subjects.hasLoadedData
          ? Static.subjects.data.getSubject(subject.subjectID)
          : null,
      titleFontWeight:
          subject.subjectID == 'Mittagspause' || subject.subjectID == 'none'
              ? FontWeight.w100
              : null,
      titleColor:
          subject.subjectID == 'Mittagspause' || subject.subjectID == 'none'
              ? Colors.black
              : Theme.of(context).accentColor,
      subtitle: subject.subjectID != 'Mittagspause'
          ? Text(
              timeStr,
              style: TextStyle(fontWeight: FontWeight.w100),
            )
          : null,
      last: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (subject.subjectID != 'Mittagspause')
            Container(
              width: 30,
              margin: EdgeInsets.only(right: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (subject.teacherID != null)
                    Text(
                      '${subject.teacherID.toUpperCase()}\n',
                      style:
                          TextStyle(fontSize: 13, fontWeight: FontWeight.w100),
                    ),
                ],
              ),
            ),
          if (subject.subjectID != 'Mittagspause')
            Container(
              width: 30,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (subject.roomID != null)
                    Text(
                      '${subject.roomID.toUpperCase()}\n',
                      style:
                          TextStyle(fontSize: 13, fontWeight: FontWeight.w100),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
