import 'package:flutter/material.dart';
import 'package:flutter_event_bus/flutter_event_bus.dart';
import 'package:substitution_plan/substitution_plan.dart';
import 'package:timetable/timetable.dart';
import 'package:utils/utils.dart';
import 'package:widgets/widgets.dart';

import 'timetable_page.dart';
import 'timetable_row.dart';

// ignore: public_member_api_docs
class TimetableInfoCard extends InfoCard {
  // ignore: public_member_api_docs
  const TimetableInfoCard({
    @required DateTime date,
    double maxHeight,
  }) : super(
          date: date,
          maxHeight: maxHeight,
        );

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
  ListGroup build(BuildContext context) {
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
    final cut = InfoCardUtils.cut(
      getScreenSize(MediaQuery.of(context).size.width),
      subjects.length,
    );
    return ListGroup(
      loadingKeys: [TimetableKeys.timetable],
      title: 'Nächste Stunden - ${weekdays[widget.date.weekday - 1]}',
      counter: subjects.length > cut ? subjects.length - cut : 0,
      heroId:
      getScreenSize(MediaQuery.of(context).size.width) == ScreenSize.small
          ? TimetableKeys.timetable
          : '${TimetableKeys.timetable}-${widget.date.weekday - 1}',
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
      maxHeight: widget.maxHeight,
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
          ...(subjects.length > cut ? subjects.sublist(0, cut) : subjects)
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
            return [
              ...getSubstitutionList(substitutions
                  .where(
                      (substitution) => substitution.unit == subject.unit)
                  .toList()),
              if (substitutions.isEmpty || showNormal)
                TimetableRow(
                  subject: subject,
                  keepUnitPadding: substitutions.isNotEmpty,
                ),
              if (undefinedSubstitutions.isNotEmpty)
                ...getSubstitutionList(
                  undefinedSubstitutions
                      .where((substitution) =>
                  substitution.unit == subject.unit)
                      .toList(),
                  showUnit: false,
                ),
            ];
          })
              .expand((x) => x)
              .cast<Widget>(),
      ],
    );
  }
}
