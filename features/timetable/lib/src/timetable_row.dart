import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:timetable/timetable.dart';
import 'package:utils/utils.dart';
import 'package:widgets/widgets.dart';

// ignore: public_member_api_docs
class TimetableRow extends PreferredSize {
  // ignore: public_member_api_docs
  const TimetableRow({
    @required this.subject,
    this.showUnit = true,
    this.showSplit = true,
    this.keepUnitPadding = false,
  }) : assert(subject != null, 'subject must not be null');

  // ignore: public_member_api_docs
  final TimetableSubject subject;

  /// If there is space for the unit of not
  final bool showUnit;

  // ignore: public_member_api_docs
  final bool showSplit;

  /// If the space should be kept where the unit was
  final bool keepUnitPadding;

  String _getWithCase(String raw) => raw.length >= 2 &&
          grades.contains(raw.substring(0, 2)) &&
          !isSeniorGrade(raw)
      ? raw
      : raw.toUpperCase();

  @override
  Size get preferredSize => Size.fromHeight(customRowHeight);

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
    final theme = ThemeWidget.of(context);
    final showCenterInfo =
        subject.subjectID == TimetableLocalizations.lunchBreak;
    final useOpacity = Static.user.isTeacher() &&
        subject.subjectID == TimetableLocalizations.freeLesson;
    final opacity = theme.brightness == Brightness.dark ? 0.65 : 0.7;
    final participants = subject.participantID?.split('\n') ?? [];
    return CustomRow(
      splitColor: Colors.transparent,
      showSplit: !showCenterInfo && showSplit,
      leading: showUnit && !showCenterInfo
          ? Text(
              !keepUnitPadding ? (unit + 1).toString() : '',
              style: TextStyle(
                fontSize: 25,
                color: useOpacity
                    ? theme.textColorLight.withOpacity(opacity -
                        (theme.brightness == Brightness.dark ? 0 : 0.3))
                    : theme.textColorLight,
                fontWeight: FontWeight.w100,
              ),
            )
          : null,
      titleAlignment:
          showCenterInfo ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      title: Static.subjects.hasLoadedData && subject.subjectID != 'none'
          ? Static.subjects.data.getSubject(subject.subjectID)
          : TimetableLocalizations.notSelected,
      titleFontWeight: showCenterInfo ? FontWeight.w100 : null,
      titleColor: showCenterInfo
          ? theme.textColor
          : useOpacity
              ? Theme.of(context).accentColor.withOpacity(opacity)
              : Theme.of(context).accentColor,
      subtitle: !showCenterInfo
          ? Text(
              subject.subjectID != 'none'
                  ? timeStr
                  : TimetableLocalizations.clickToSelect,
              style: TextStyle(
                color: useOpacity
                    ? theme.textColor.withOpacity(opacity)
                    : theme.textColor,
                fontWeight: FontWeight.w100,
              ),
            )
          : null,
      last: subject.subjectID != 'none'
          ? !showCenterInfo
          ? Row(
        children: [
          Container(
            width: 35,
            margin: EdgeInsets.only(right: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (participants.isNotEmpty)
                  Text(
                    _getWithCase(participants[0]),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w300,
                      color: theme.textColor,
                      fontFamily: 'RobotoMono',
                    ),
                  ),
                Text(
                  participants.length > 1 ? _getWithCase(participants[1]) : '',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w300,
                    color: theme.textColor,
                    decoration: TextDecoration.lineThrough,
                    fontFamily: 'RobotoMono',
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 30,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  subject.roomID,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w300,
                    color: theme.textColor,
                    fontFamily: 'RobotoMono',
                  ),
                ),
                Text(''),
              ],
            ),
          ),
        ],
      )
          : Container()
          : Icon(
        MdiIcons.exclamation,
        color: theme.textColorLight,
      ),
    );
  }
}
