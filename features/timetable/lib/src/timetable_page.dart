import 'package:cafetoria/cafetoria.dart';
import 'package:calendar/calendar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_event_bus/flutter_event_bus.dart';
import 'package:subjects/subjects.dart';
import 'package:substitution_plan/substitution_plan.dart';
import 'package:timetable/timetable.dart';
import 'package:utils/utils.dart';
import 'package:widgets/widgets.dart';

// ignore: public_member_api_docs
class TimetablePage extends StatefulWidget {
  // ignore: public_member_api_docs
  const TimetablePage({Key key}) : super(key: key);

  @override
  _TimetablePageState createState() => _TimetablePageState();
}

class _TimetablePageState extends Interactor<TimetablePage> {
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
    final calendar = CalendarWidget.of(context)?.feature?.loader;
    if (calendar != null &&
        calendar.hasLoadedData &&
        calendar.data.getEventsForDate(day).isNotEmpty) {
      calendarCount++;
    }
    return calendarCount;
  }

  @override
  Widget build(BuildContext context) {
    final loader = TimetableWidget.of(context).feature.loader;
    final _monday = monday(loader.hasLoadedData
        ? loader.data.initialDay(DateTime.now())
        : DateTime.now());
    return Scaffold(
      appBar: CustomAppBar(
        title: TimetableLocalizations.name,
        loadingKeys: [
          TimetableKeys.timetable,
          SubstitutionPlanKeys.substitutionPlan,
          SubjectsKeys.subjects,
          Keys.tags,
        ],
      ),
      body: CustomHero(
        tag: TimetableKeys.timetable,
        child: loader.hasLoadedData
            ? CustomGrid(
                onRefresh: () async {
                  final results = [
                    await Static.tags.syncToServer(
                      context,
                      [TimetableWidget.of(context).feature],
                    ),
                    await loader.loadOnline(context, force: true),
                    if (SubstitutionPlanWidget.of(context) != null)
                      await SubstitutionPlanWidget.of(context)
                          .feature
                          .loader
                          .loadOnline(context, force: true),
                  ];
                  return reduceStatusCodes(results);
                },
                initialHorizontalIndex:
                    loader.data.initialDay(DateTime.now()).weekday - 1,
                type: getScreenSize(MediaQuery.of(context).size.width) ==
                        ScreenSize.big
                    ? CustomGridType.grid
                    : CustomGridType.tabs,
                columnPrepend: weekdays.values
                    .toList()
                    .sublist(0, 5)
                    .map((weekday) =>
                        getScreenSize(MediaQuery.of(context).size.width) ==
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
                          color: ThemeWidget.of(context).textColor,
                        ),
                      ),
                    ),
                  ),
                ),
                extraInfoRowPrepend: [
                  Container(
                    height: 60,
                    child: Center(
                      child: Text(
                        CalendarLocalizations.events,
                        style: TextStyle(
                          fontSize: 16,
                          color: ThemeWidget.of(context).textColor,
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
                          color: ThemeWidget.of(context).textColor,
                        ),
                      ),
                    ),
                  ),
                ],
                extraInfoTitles: List.generate(5, (weekday) {
                  final day = _monday.add(Duration(days: weekday));
                  return '${weekdays[day.weekday - 1]} ${shortOutputDateFormat.format(day)}';
                }),
                extraInfoCounts: List.generate(5, (weekday) {
                  final day = _monday.add(Duration(days: weekday));
                  return getCafetoriaCount(day) + getCalendarCount(day);
                }),
                extraInfoChildren: List.generate(5, (weekday) {
                  final day = _monday.add(Duration(days: weekday));
                  final isSmall =
                      getScreenSize(MediaQuery.of(context).size.width) ==
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
                  ].map((x) => SizeLimit(child: x)).toList().cast<Widget>();
                }),
                children: List.generate(
                  5,
                  (weekday) => loader.data.days[weekday].units.isEmpty
                      ? [
                          Container(
                            padding: EdgeInsets.only(top: 20),
                            child: EmptyList(
                              title: TimetableLocalizations.noClasses,
                            ),
                          )
                        ]
                      : loader.data.days[weekday].units.map((unit) {
                          final day = _monday.add(Duration(days: weekday));
                          final subject = loader.data.selection
                              .getSelectedSubject(unit.subjects);
                          // ignore: omit_local_variable_types
                          final List<Substitution> substitutions =
                              SubstitutionPlanWidget.of(context) != null
                                  ? subject?.getSubstitutions(
                                          day,
                                          SubstitutionPlanWidget.of(context)
                                              .feature
                                              .loader
                                              .data) ??
                                      []
                                  : [];
                          // Show the normal lessen if it is an exam, but not of the same subjects, as this unit
                          final showNormal = substitutions.length == 1 &&
                              substitutions.first.type == 2 &&
                              substitutions.first.courseID != subject.courseID;
                          final List<Substitution> undefinedSubstitutions =
                              SubstitutionPlanWidget.of(context) != null
                                  ? subject?.getUndefinedSubstitutions(
                                          day,
                                          SubstitutionPlanWidget.of(context)
                                              .feature
                                              .loader
                                              .data) ??
                                      []
                                  : [];
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
                                        loader.data.selection
                                            .setSelectedSubject(
                                          selection,
                                          EventBus.of(context),
                                          SubstitutionPlanWidget.of(context)
                                              ?.feature
                                              ?.loader
                                              ?.data,
                                          loader.data,
                                        );
                                        setState(() {});
                                        await loader.data.selection
                                            .save(context);
                                        if (mounted) {
                                          setState(() {});
                                        }
                                      }
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
