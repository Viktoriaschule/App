import 'package:intl/intl.dart';

import 'package:flutter/material.dart';
import 'package:reservations/reservations.dart';
import 'package:reservations/src/reservations_localizations.dart';
import 'package:reservations/src/reservations_model.dart';
import 'package:timetable/timetable.dart';
import 'package:utils/utils.dart';
import 'package:widgets/widgets.dart';

/// A dialog to create a new reservation
class NewReservationDialog extends StatefulWidget {
  // ignore: public_member_api_docs
  const NewReservationDialog({@required this.onFinished});

  /// Finish callback
  final VoidCallback onFinished;

  @override
  State<StatefulWidget> createState() => NewReservationDialogState();
}

// ignore: public_member_api_docs
class NewReservationDialogState extends State<NewReservationDialog> {
  @override
  Widget build(BuildContext context) {
    final loader = ReservationsWidget.of(context).feature.loader;
    return SimpleDialog(
      titlePadding: EdgeInsets.all(0),
      title: Center(
        child: Padding(
          padding: EdgeInsets.only(top: 10),
          child: Text(
            ReservationsLocalizations.newReservation,
            style: TextStyle(fontWeight: FontWeight.w100),
          ),
        ),
      ),
      children: [TimetableSubjectSelect()],
    );
  }
}

/// A timetable subject selection widget
class TimetableSubjectSelect extends StatefulWidget {
  @override
  _TimetableSubjectSelectState createState() => _TimetableSubjectSelectState();
}

class _TimetableSubjectSelectState extends State<TimetableSubjectSelect> {
  TimetableSubject subject;
  DateTime date;
  List<DateTime> dates = [];
  PriorityLevel priorityLevel = PriorityLevel.normal;

  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();

  Future getIpadGroups() async {}

  Future selectSubject() async {
    final subject = await Navigator.of(context).push<TimetableSubject>(
      MaterialPageRoute(
        builder: (context) => TimetablePage(selectionMode: true),
      ),
    );

    if (subject == null) {
      return;
    }

    final dates = <DateTime>[];
    final now = DateTime.now();
    DateTime date = DateTime(now.year, now.month, now.day);

    // Set the correct weekday and time
    date = date.add(Duration(
      days: subject.day + 1 - date.weekday,
      minutes: Times.getUnitTimes(subject.unit)[0].inMinutes,
    ));

    if (date.isBefore(now.add(Duration(hours: 1)))) {
      date = date.add(Duration(days: 7));
    }

    this.date = date;

    for (int i = 0; i < 3; i++) {
      dates.add(date);
      date = date.add(Duration(days: 7));
    }

    setState(() {
      this.subject = subject;
      this.dates = dates;
    });
  }

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(left: 10, right: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (subject == null)
              Padding(
                padding: const EdgeInsets.all(10),
                child: InkWell(
                  onTap: selectSubject,
                  child: Container(
                    height: 60,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.white,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    child: Center(
                      child: Text(ReservationsLocalizations.selectSubject),
                    ),
                  ),
                ),
              ),
            if (subject != null) ...[
              Padding(
                padding: const EdgeInsets.only(left: 20, bottom: 0),
                child: Row(
                  children: [
                    Expanded(
                      flex: 80,
                      child: Text(
                        ReservationsLocalizations.selectedSubject,
                        style: TextStyle(fontWeight: FontWeight.w100),
                      ),
                    ),
                    Expanded(
                      flex: 20,
                      child: Container(
                        height: 20,
                        child: IconButton(
                          padding: EdgeInsets.all(0),
                          onPressed: selectSubject,
                          icon: Icon(Icons.edit),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              TimetableRow(subject: subject),
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 10, top: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ReservationsLocalizations.selectedDate,
                      style: TextStyle(fontWeight: FontWeight.w100),
                    ),
                    DropdownButton<DateTime>(
                      value: date,
                      isExpanded: true,
                      onChanged: (date) => setState(() => this.date = date),
                      items: dates
                          .map((e) => DropdownMenuItem(
                                value: e,
                                child: Text(
                                    DateFormat.yMMMMd('de').add_Hm().format(e)),
                              ))
                          .toList(),
                    ),
                    Container(height: 20),
                    Text(
                      ReservationsLocalizations.priority,
                      style: TextStyle(fontWeight: FontWeight.w100),
                    ),
                    DropdownButton<PriorityLevel>(
                      value: priorityLevel,
                      isExpanded: true,
                      onChanged: (priority) =>
                          setState(() => priorityLevel = priority),
                      items: PriorityLevel.values
                          .map((e) => DropdownMenuItem(
                                value: e,
                                child: Text(e.displayName),
                              ))
                          .toList(),
                    ),
                    if (priorityLevel == PriorityLevel.high)
                      Form(
                        key: _formKey,
                        child: TextFormField(
                          controller: _reasonController,
                          autovalidate: true,
                          decoration: InputDecoration(
                            hintText: ReservationsLocalizations.reason,
                          ),
                          validator: (value) {
                            if (value.isEmpty) {
                              return ReservationsLocalizations
                                  .reasonMustNotBeNull;
                            }
                            return null;
                          },
                        ),
                      ),
                    Container(height: 20),
                    Text(
                      ReservationsLocalizations.iPadGroup,
                      style: TextStyle(fontWeight: FontWeight.w100),
                    ),
                    DropdownButton<PriorityLevel>(
                      value: priorityLevel,
                      isExpanded: true,
                      onChanged: (priority) =>
                          setState(() => priorityLevel = priority),
                      items: PriorityLevel.values
                          .map((e) => DropdownMenuItem(
                                value: e,
                                child: Text(e.displayName),
                              ))
                          .toList(),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      );
}
