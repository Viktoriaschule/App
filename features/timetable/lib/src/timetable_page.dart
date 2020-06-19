import 'package:cafetoria/cafetoria.dart';
import 'package:calendar/calendar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_event_bus/flutter_event_bus.dart';
import 'package:substitution_plan/substitution_plan.dart';
import 'package:timetable/timetable.dart';
import 'package:utils/utils.dart';
import 'package:widgets/widgets.dart';

// ignore: public_member_api_docs
class TimetablePage extends StatefulWidget {
  // ignore: public_member_api_docs
  const TimetablePage({Key key, this.selectionMode = false}) : super(key: key);

  /// The timetable page to select any subject
  final bool selectionMode;

  @override
  _TimetablePageState createState() => _TimetablePageState();
}

class _TimetablePageState extends Interactor<TimetablePage> {
  String group;
  Timetable data;

  @override
  Subscription subscribeEvents(EventBus eventBus) => eventBus
      .respond<TagsUpdateEvent>((event) => setState(() => null))
      .respond<SubstitutionPlanUpdateEvent>((event) => setState(() => null))
      .respond<TimetableUpdateEvent>((event) => setState(() => null));

  int getCafetoriaCount(DateTime day) {
    // Check cafetoria
    int cafetoriaCount = 0;
    final cafetoria = CafetoriaWidget.of(context)?.feature?.loader;
    if (cafetoria != null && cafetoria.hasLoadedData) {
      final days = cafetoria.data.days.where((d) => d.date == day);
      if (days.isNotEmpty && days.first.menus.isNotEmpty) {
        cafetoriaCount++;
      }
    }
    return cafetoriaCount;
  }

  int getCalendarCount(DateTime day) {
    // Check calendar
    int calendarCount = 0;
    final calendar = CalendarWidget
        .of(context)
        ?.feature
        ?.loader;
    if (calendar != null &&
        calendar.hasLoadedData &&
        calendar.data
            .getEventsForDate(day)
            .isNotEmpty) {
      calendarCount++;
    }
    return calendarCount;
  }

  Future<void> loadOtherTimetable(BuildContext context, TimetableLoader loader,
      String group) async {
    if (group == loader.data.group) {
      updateTimetable(loader.data);
      return;
    }

    final offlineResult =
    await loader.loadOtherTimetable(context, group, online: false);
    updateTimetable(offlineResult);

    final onlineResult = await loader.loadOtherTimetable(context, group);
    updateTimetable(onlineResult);
  }

  void updateTimetable(Timetable timetable) {
    setState(() {
      data = timetable ??
          Timetable(
            days: List.generate(
              5,
                  (index) => TimetableDay(units: [], day: index),
            ),
            date: DateTime.now(),
            group: group,
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final loader = TimetableWidget
        .of(context)
        .feature
        .loader;
    Timetable data = loader.data;
    bool hasLoadedData = loader.hasLoadedData;

    if (widget.selectionMode) {
      if (group == null) {
        group = Static.user.group;
        this.data = loader.data;
      }
      data = this.data;
      hasLoadedData = data != null;
    }

    final substitutionPlanFeature = SubstitutionPlanWidget
        .of(context)
        .feature;
    final _monday = monday(
        hasLoadedData ? data.initialDay(DateTime.now()) : DateTime.now());
    return Scaffold(
      appBar: CustomAppBar(
        title: widget.selectionMode
            ? TimetableLocalizations.selectSubject
            : TimetableLocalizations.name,
        loadingKeys: [
          TimetableKeys.timetable,
          substitutionPlanFeature.featureKey,
          Keys.tags
        ],
        actions: [
          if (widget.selectionMode)
            Container(
              width: 48,
              child: DropdownButton<String>(
                  underline: Container(),
                  value: group,
                  items: grades
                      .map(
                        (grade) =>
                        DropdownMenuItem(
                          value: grade,
                          child: Text(
                            isSeniorGrade(grade) ? grade.toUpperCase() : grade,
                            style: TextStyle(fontWeight: FontWeight.w100),
                          ),
                        ),
                  )
                      .toList(),
                  onChanged: (grade) {
                    setState(() {
                      group = grade;
                      loadOtherTimetable(context, loader, group);
                    });
                  }),
            ),
        ],
      ),
      body: CustomHero(
        tag: TimetableKeys.timetable,
        child: hasLoadedData && substitutionPlanFeature.loader.hasLoadedData
            ? CustomGrid(
          onRefresh: () async {
            if (widget.selectionMode && group != Static.user.group) {
              await loadOtherTimetable(context, loader, group);
              return StatusCode.success;
            }
            final results = [
              await Static.tags.syncToServer(
                context,
                [TimetableWidget
                    .of(context)
                    .feature
                ],
              ),
              await loader.loadOnline(context, force: true),
              await substitutionPlanFeature.loader
                  .loadOnline(context, force: true),
            ];
            return reduceStatusCodes(results);
          },
          initialHorizontalIndex:
          data
              .initialDay(DateTime.now())
              .weekday - 1,
          type: getScreenSize(MediaQuery
              .of(context)
              .size
              .width) ==
              ScreenSize.big
              ? CustomGridType.grid
              : CustomGridType.tabs,
          columnPrepend: weekdays.values
              .toList()
              .sublist(0, 5)
              .map((weekday) =>
          getScreenSize(MediaQuery
              .of(context)
              .size
              .width) ==
              ScreenSize.small
              ? weekday.substring(0, 2).toUpperCase()
              : weekday)
              .toList(),
          childrenRowPrepend: List.generate(
            8,
                (index) => Container(
              height: 60,
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    fontSize: 16,
                    color: ThemeWidget
                        .of(context)
                        .textColor,
                  ),
                ),
              ),
            ),
          ),
          extraInfoRowPrepend: widget.selectionMode
              ? null
              : [
            Container(
              height: 60,
              child: Center(
                child: Text(
                  CalendarLocalizations.events,
                  style: TextStyle(
                    fontSize: 16,
                    color: ThemeWidget
                        .of(context)
                        .textColor,
                  ),
                ),
              ),
            ),
            Container(
              height: 60,
              child: Center(
                child: Text(
                  CafetoriaLocalizations.menus,
                  style: TextStyle(
                    fontSize: 16,
                    color: ThemeWidget
                        .of(context)
                        .textColor,
                  ),
                ),
              ),
            ),
          ],
          extraInfoTitles: widget.selectionMode
              ? null
              : List.generate(5, (weekday) {
            final day = _monday.add(Duration(days: weekday));
            return '${weekdays[day.weekday - 1]} ${shortOutputDateFormat.format(
                day)}';
          }),
          extraInfoCounts: widget.selectionMode
              ? null
              : List.generate(5, (weekday) {
            final day = _monday.add(Duration(days: weekday));
            return getCafetoriaCount(day) + getCalendarCount(day);
          }),
          extraInfoChildren: widget.selectionMode
              ? null
              : List.generate(5, (weekday) {
            final day = _monday.add(Duration(days: weekday));
            final isSmall =
                getScreenSize(MediaQuery
                    .of(context)
                    .size
                    .width) ==
                    ScreenSize.small;
            return [
              if (CafetoriaWidget.of(context) != null &&
                  (isSmall || getCafetoriaCount(day) > 0))
                CafetoriaInfoCard(
                  date: day,
                  showNavigation: false,
                  isSingleDay: true,
                ),
              if (CalendarWidget.of(context) != null &&
                  (isSmall || getCalendarCount(day) > 0))
                CalendarInfoCard(
                  date: day,
                  showNavigation: false,
                  isSingleDay: true,
                ),
            ]
                .map((x) => SizeLimit(child: x))
                .toList()
                .cast<Widget>();
          }),
          children: List.generate(
            5,
                (weekday) =>
            data.days[weekday].units.isEmpty
                ? [
              Container(
                padding: EdgeInsets.only(top: 20),
                child: EmptyList(
                  title: TimetableLocalizations.noSubjects,
                ),
              )
            ]
                : data.days[weekday].units.map((unit) {
              final day = _monday.add(Duration(days: weekday));
              TimetableSubject subject =
              data.selection.getSelectedSubject(unit.subjects);
              // ignore: omit_local_variable_types
              final List<Substitution> substitutions =
                  subject?.getSubstitutions(day,
                      substitutionPlanFeature.loader.data) ??
                      [];
              // Show the normal lessen if it is an exam, but not of the same subjects, as this unit
              final showNormal = substitutions.length == 1 &&
                  substitutions.first.type == 2 &&
                  substitutions.first.courseID != subject.courseID;
              final List<Substitution> undefinedSubstitutions =
                  subject?.getUndefinedSubstitutions(day,
                      substitutionPlanFeature.loader.data) ??
                      [];

              if (widget.selectionMode) {
                if (group != Static.user.group) {
                  substitutions.clear();
                  undefinedSubstitutions.clear();
                }
                subject ??= unit.subjects.isEmpty
                    ? null
                    : unit.subjects.length > 1
                    ? unit.subjects[1]
                    : unit.subjects.first;
              }
              return SizeLimit(
                child: Material(
                  child: InkWell(
                    onTap: unit.subjects.length > 1
                        ? () async {
                      // ignore: omit_local_variable_types
                      final TimetableSubject selection =
                      await showDialog(
                        context: context,
                        builder: (context) =>
                            TimetableSelectDialog(
                              weekday: weekday,
                              unit: unit,
                            ),
                      );
                      if (selection == null) {
                        return;
                      }
                      if (widget.selectionMode) {
                        Navigator.of(context).pop(selection);
                        return;
                      }
                      data.selection.setSelectedSubject(
                        selection,
                        EventBus.of(context),
                        substitutionPlanFeature.loader.data,
                        data,
                      );
                      setState(() {});
                      await data.selection.save(context);
                      if (mounted) {
                        setState(() {});
                      }
                    }
                        : widget.selectionMode
                        ? () =>
                        Navigator.of(context).pop(subject)
                        : null,
                    child: Column(
                      children: [
                        if (substitutions.isNotEmpty)
                          ...getSubstitutionList(
                            substitutions
                                .where((substitution) =>
                            substitution.unit ==
                                subject.unit)
                                .toList(),
                            showUnit: getScreenSize(
                                MediaQuery.of(context)
                                    .size
                                    .width) !=
                                ScreenSize.big,
                            keepUnitPadding: getScreenSize(
                                MediaQuery.of(context)
                                    .size
                                    .width) !=
                                ScreenSize.big,
                          ),
                        if (substitutions.isEmpty || showNormal)
                          TimetableRow(
                            subject: subject ??
                                TimetableSubject(
                                  unit: unit.unit,
                                  subjectID: 'none',
                                  participantID: null,
                                  roomID: null,
                                  courseID: '',
                                  id: '',
                                  day: weekday,
                                  block: '',
                                ),
                            keepUnitPadding:
                            substitutions.isNotEmpty,
                            showUnit: getScreenSize(
                                MediaQuery.of(context)
                                    .size
                                    .width) !=
                                ScreenSize.big,
                          ),
                        if (undefinedSubstitutions.isNotEmpty)
                          ...getSubstitutionList(
                            undefinedSubstitutions
                                .where((substitution) =>
                            substitution.unit ==
                                subject.unit)
                                .toList(),
                            showUnit: false,
                            keepUnitPadding: getScreenSize(
                                MediaQuery.of(context)
                                    .size
                                    .width) !=
                                ScreenSize.big,
                          ),
                      ]
                          .map((x) => Container(
                        height: 60,
                        child: x,
                      ))
                          .toList()
                          .cast<Widget>(),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        )
            : Center(
          child: EmptyList(
            title: TimetableLocalizations.noTimetable,
          ),
        ),
      ),
    );
  }
}
