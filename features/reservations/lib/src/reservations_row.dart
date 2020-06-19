import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:reservations/src/reservations_model.dart';
import 'package:timetable/timetable.dart';
import 'package:utils/utils.dart';
import 'package:widgets/widgets.dart';

// ignore: public_member_api_docs
class ReservationRow extends PreferredSize {
  // ignore: public_member_api_docs
  const ReservationRow({
    @required this.reservation,
    this.subject,
  });

  // ignore: public_member_api_docs
  final Reservation reservation;

  /// The timetable subject for this reservation
  final TimetableSubject subject;

  @override
  Size get preferredSize => Size.fromHeight(customRowHeight);

  String _getWithCase(String raw) =>
      isSeniorGrade(raw) ? raw.toUpperCase() : raw;

  @override
  Widget build(BuildContext context) {
    final theme = ThemeWidget.of(context);
    return CustomRow(
      splitColor: Colors.transparent,
      leading: Text(
        reservation.timetableID != null
            ? reservation.timetableID.split('-')[3]
            : '-',
        style: TextStyle(
          fontSize: 25,
          color: theme.textColorLight,
          fontWeight: FontWeight.w100,
        ),
      ),
      title: Static.subjects.hasLoadedData
          ? Static.subjects.data.getSubject(
              subject?.subjectID ?? weekdays[reservation.date.weekday])
          : subject?.subjectID ?? weekdays[reservation.date.weekday],
      titleColor: Theme.of(context).accentColor,
      subtitle: Text(
        DateFormat.yMMMMd('de').format(reservation.date),
        style: TextStyle(
          color: theme.textColor,
          fontWeight: FontWeight.w100,
        ),
      ),
      last: Row(
        children: [
          Container(
            width: 35,
            margin: EdgeInsets.only(right: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (subject != null)
                  Text(
                    reservation.groupID.toString().padLeft(2, '0'),
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
          Container(
            width: 30,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  reservation.timetableID != null
                      ? _getWithCase(reservation.timetableID.split('-')[0])
                      : '',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w300,
                    color: theme.textColor,
                    fontFamily: 'RobotoMono',
                  ),
                ),
                Text(
                  subject != null ? subject.roomID : '',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w300,
                    color: theme.textColor,
                    fontFamily: 'RobotoMono',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
