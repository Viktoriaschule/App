import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:utils/utils.dart';
import 'package:widgets/widgets.dart';

import 'timetable_model.dart';

// ignore: public_member_api_docs
class TimetableRow extends StatelessWidget {
  // ignore: public_member_api_docs
  const TimetableRow({
    @required this.subject,
    this.showUnit = true,
    this.showSplit = true,
    this.hideUnit = false,
    Key key,
  })  : assert(subject != null, 'subject must not be null'),
        super(key: key);

  // ignore: public_member_api_docs
  final TimetableSubject subject;

  /// If there is space for the unit of not
  final bool showUnit;

  // ignore: public_member_api_docs
  final bool showSplit;

  /// If the unit should be hide, but the space should still be there
  final bool hideUnit;

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
      showSplit: !(subject.subjectID == 'Mittagspause') && showSplit,
      leading: showUnit && unit != 5
          ? Align(
              alignment: Alignment(0.3, 0),
              child: Text(
                !hideUnit ? (unit + 1).toString() : '',
                style: TextStyle(
                  fontSize: 25,
                  color: ThemeWidget
                      .of(context)
                      .textColorLight,
                  fontWeight: FontWeight.w100,
                ),
              ),
            )
          : null,
      titleAlignment: subject.subjectID == 'Mittagspause'
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      title: Static.subjects.hasLoadedData && subject.subjectID != 'none'
          ? Static.subjects.data.getSubject(subject.subjectID)
          : 'Nicht ausgewählt',
      titleFontWeight:
          subject.subjectID == 'Mittagspause' ? FontWeight.w100 : null,
      titleColor: subject.subjectID == 'Mittagspause'
          ? ThemeWidget.of(context).textColor
          : Theme.of(context).accentColor,
      subtitle: subject.subjectID != 'Mittagspause'
          ? Text(
              subject.subjectID != 'none' ? timeStr : 'Klicke zum Auswählen',
              style: TextStyle(
                color: ThemeWidget.of(context).textColor,
                fontWeight: FontWeight.w100,
              ),
            )
          : null,
      last: subject.subjectID != 'none'
          ? Row(
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
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w300,
                              color: ThemeWidget.of(context).textColor,
                              fontFamily: 'RobotoMono',
                            ),
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
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w300,
                              color: ThemeWidget.of(context).textColor,
                              fontFamily: 'RobotoMono',
                            ),
                          ),
                      ],
                    ),
                  ),
              ],
            )
          : Icon(
              MdiIcons.exclamation,
              color: ThemeWidget.of(context).textColorLight,
            ),
    );
  }
}
