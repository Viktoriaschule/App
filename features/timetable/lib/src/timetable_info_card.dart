import 'package:flutter/material.dart';
import 'package:flutter_event_bus/flutter_event_bus.dart';
import 'package:substitution_plan/substitution_plan.dart';
import 'package:timetable/timetable.dart';
import 'package:utils/utils.dart';
import 'package:widgets/widgets.dart';

// ignore: public_member_api_docs
class TimetableInfoCard extends InfoCard {
  // ignore: public_member_api_docs
  const TimetableInfoCard({DateTime date}) : super(date: date);

  @override
  _TimetableInfoCardState createState() => _TimetableInfoCardState();
}

class _TimetableInfoCardState extends InfoCardState<TimetableInfoCard> {
  @override
  Subscription subscribeEvents(EventBus eventBus) => eventBus
      .respond<TagsUpdateEvent>((event) => setState(() => null))
      .respond<TimetableUpdateEvent>((event) => setState(() => null))
      .respond<SubstitutionPlanUpdateEvent>((event) => setState(() => null));

  @override
  ListGroup getListGroup(BuildContext context, InfoCardUtils utils) {
    final group = Static.user.group;
    final loader = TimetableWidget.of(context).feature.loader;
    final spLoader = SubstitutionPlanWidget.of(context).feature.loader;
    final subjects = loader.hasLoadedData
        ? loader.data.days[widget.date.weekday - 1]
            .getFutureSubjects(widget.date, loader.data.selection)
            .where((subject) =>
                subject.subjectID != SubstitutionPlanLocalizations.freeLesson ||
                subject.getSubstitutions(widget.date, spLoader.data).isNotEmpty)
            .toList()
        : <TimetableSubject>[];
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
                  !loader.data.selection.isSet(group))
                EmptyList(
                    title: loader.data?.selection?.isSet(group) ?? true
                        ? loader.hasLoadedData && subjects.isEmpty
                        ? TimetableLocalizations.noSubjects
                        : TimetableLocalizations.noTimetable
                        : TimetableLocalizations.notSelected)
              else
                ...(subjects.length > utils.cut
                    ? subjects.sublist(0, utils.cut)
                    : subjects)
                    .map((subject) {
                  final substitutions = spLoader.hasLoadedData
                      ? subject.getSubstitutions(widget.date, spLoader.data)
                      : <Substitution>[];
                  // Show the normal lessen if it is an exam, but not of the same subjects, as this unit
                  final showNormal = substitutions.length == 1 &&
                      substitutions.first.type == 2 &&
                      substitutions.first.courseID != subject.courseID;
                  final List<Substitution> undefinedSubstitutions =
                      subject?.getUndefinedSubstitutions(
                          widget.date, spLoader.data) ??
                          [];
                  return Container(
                    margin: EdgeInsets.all(10),
                    child: Column(
                      children: [
                        SubstitutionList(
                          substitutions: substitutions
                              .where((substitution) =>
                          substitution.unit == subject.unit)
                              .toList(),
                          padding: false,
                        ),
                        if (substitutions.isEmpty || showNormal)
                          Padding(
                            padding: EdgeInsets.only(
                                top: substitutions.isNotEmpty ? 5 : 0),
                            child: TimetableRow(
                              subject: subject,
                              hideUnit: substitutions.isNotEmpty,
                            ),
                          ),
                        if (undefinedSubstitutions.isNotEmpty)
                          SubstitutionList(
                            showUnit: false,
                            padding: false,
                            substitutions: undefinedSubstitutions
                                .where((substitution) =>
                            substitution.unit == subject.unit)
                                .toList(),
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
