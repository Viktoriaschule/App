import 'package:flutter/material.dart';
import 'package:flutter_event_bus/flutter_event_bus.dart';
import 'package:substitution_plan/substitution_plan.dart';
import 'package:timetable/src/timetable_keys.dart';
import 'package:timetable/timetable.dart';
import 'package:utils/utils.dart';
import 'package:widgets/widgets.dart';

import 'timetable_page.dart';
import 'timetable_row.dart';

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

  @override
  Subscription subscribeEvents(EventBus eventBus) => eventBus
      .respond<TagsUpdateEvent>((event) => setState(() => null))
      .respond<TimetableUpdateEvent>((event) => setState(() => null))
      .respond<SubstitutionPlanUpdateEvent>((event) => setState(() => null));

  @override
  Widget build(BuildContext context) {
    final loader = TimetableWidget.of(context).feature.loader;
    final subjects = loader.hasLoadedData
        ? loader.data.days[widget.date.weekday - 1]
            .getFutureSubjects(widget.date, loader.data.selection)
        : [];
    utils ??= InfoCardUtils(context, widget.date);
    return ListGroup(
      loadingKeys: [TimetableKeys.timetable],
      title: 'Nächste Stunden - ${weekdays[widget.date.weekday - 1]}',
      counter: subjects.length > utils.cut ? subjects.length - utils.cut : 0,
      heroId: utils.size == ScreenSize.small
          ? TimetableKeys.timetable
          : '${TimetableKeys.timetable}-${utils.weekday}',
      heroIdNavigation: TimetableKeys.timetable,
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
              if (subjects.isEmpty ||
                  !loader.hasLoadedData ||
                  !loader.data.selection.isSet())
                EmptyList(
                    title: loader.data.selection.isSet()
                        ? 'Kein Stundenplan'
                        : 'Keine Stunden ausgewählt')
              else
                ...(subjects.length > utils.cut
                        ? subjects.sublist(0, utils.cut)
                        : subjects)
                    .map((subject) {
                  final substitutions = subject.getSubstitutions(widget.date);
                  return Container(
                    margin: EdgeInsets.all(10),
                    child: Column(
                      children: [
                        if (substitutions.isEmpty)
                          TimetableRow(
                            subject: subject,
                          ),
                        SubstitutionList(
                          substitutions: substitutions
                              .where((substitution) =>
                                  substitution.unit == subject.unit)
                              .toList(),
                          keepPadding: true,
                          topPadding: false,
                        ),
                      ],
                    ),
                  );
                }),
            ],
          ),
        ),
      ],
    );
  }
}
