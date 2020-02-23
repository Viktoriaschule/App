import 'package:flutter/material.dart';
import 'package:flutter_event_bus/flutter_event_bus.dart';
import 'package:viktoriaapp/models/models.dart';
import 'package:viktoriaapp/substitution_plan/substitution_plan_row.dart';
import 'package:viktoriaapp/timetable/timetable_page.dart';
import 'package:viktoriaapp/timetable/timetable_row.dart';
import 'package:viktoriaapp/utils/events.dart';
import 'package:viktoriaapp/utils/info_card.dart';
import 'package:viktoriaapp/utils/screen_sizes.dart';
import 'package:viktoriaapp/utils/static.dart';
import 'package:viktoriaapp/widgets/custom_bottom_navigation.dart';
import 'package:viktoriaapp/widgets/empty_list.dart';
import 'package:viktoriaapp/widgets/list_group.dart';
import 'package:viktoriaapp/widgets/size_limit.dart';

// ignore: public_member_api_docs
class TimetableInfoCard extends StatefulWidget {
  // ignore: public_member_api_docs
  const TimetableInfoCard({
    @required this.date,
    Key key,
  }) : super(key: key);

  // ignore: public_member_api_docs
  final DateTime date;

  @override
  _TimetableInfoCardState createState() => _TimetableInfoCardState();
}

class _TimetableInfoCardState extends Interactor<TimetableInfoCard> {
  InfoCardUtils utils;

  List<TimetableSubject> _subjects;
  List<Substitution> _substitutions;

  List<TimetableSubject> getSubjects() => Static.timetable.hasLoadedData
      ? Static.timetable.data.days[widget.date.weekday - 1].units
          .map((unit) => Static.selection.getSelectedSubject(unit.subjects))
          .where((subject) =>
              subject != null &&
              subject.subjectID != 'Mittagspause' &&
              DateTime.now().isBefore(
                  widget.date.add(Times.getUnitTimes(subject.unit)[1])))
          .toList()
      : [];

  List<Substitution> getSubstitutions() {
    final spDay = Static.substitutionPlan.data?.getForDate(widget.date);
    return spDay?.myChanges ?? [];
  }

  @override
  void initState() {
    _subjects = getSubjects();
    _substitutions = getSubstitutions();
    super.initState();
  }

  @override
  Subscription subscribeEvents(EventBus eventBus) => eventBus
      .respond<TimetableUpdateEvent>(update)
      .respond<SubstitutionPlanUpdateEvent>(update);

  // ignore: type_annotate_public_apis
  void update(event) => setState(() {
        _subjects = getSubjects();
        _substitutions = getSubstitutions();
      });

  @override
  Widget build(BuildContext context) {
    utils ??= InfoCardUtils(context, widget.date);
    return ListGroup(
      pageKey: Keys.timetable,
      title: 'Nächste Stunden - ${weekdays[utils.weekday]}',
      counter: _subjects.length > utils.cut ? _subjects.length - utils.cut : 0,
      heroId: utils.size == ScreenSize.small
          ? Keys.timetable
          : '${Keys.timetable}-${utils.weekday}',
      heroIdNavigation: Keys.timetable,
      actions: [
        NavigationAction(
          Icons.expand_more,
          () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (context) => TimetablePage()),
            );
          },
        ),
      ],
      children: [
        SizeLimit(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_subjects.isEmpty ||
                  !Static.timetable.hasLoadedData ||
                  !Static.selection.isSet())
                EmptyList(title: 'Kein Stundenplan')
              else
                ...(_subjects.length > utils.cut
                        ? _subjects.sublist(0, utils.cut)
                        : _subjects)
                    .map(
                  (subject) => Container(
                    margin: EdgeInsets.all(10),
                    child: Column(
                      children: [
                        TimetableRow(
                          subject: subject,
                        ),
                        ..._substitutions
                            .where((substitution) =>
                                substitution.unit == subject.unit)
                            .map((substitution) => SubstitutionPlanRow(
                                  substitution: substitution,
                                  showUnit: false,
                                  keepPadding: true,
                                ))
                            .toList()
                            .cast<Widget>(),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
