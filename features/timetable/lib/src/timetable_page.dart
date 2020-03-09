import 'package:cafetoria/cafetoria.dart';
import 'package:calendar/calendar.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_event_bus/flutter_event_bus.dart';
import 'package:substitution_plan/substitution_plan.dart';
import 'package:timetable/src/timetable_keys.dart';
import 'package:timetable/timetable.dart';
import 'package:utils/utils.dart';
import 'package:widgets/widgets.dart';

import 'timetable_model.dart';
import 'timetable_row.dart';
import 'timetable_select_dialog.dart';

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

  @override
  Widget build(BuildContext context) {
    final loader = TimetableWidget.of(context).feature.loader;
    final substitutionPlanFeature = SubstitutionPlanWidget.of(context).feature;
    final _monday = monday(loader.hasLoadedData
        ? loader.data.initialDay(DateTime.now())
        : DateTime.now());
    return Scaffold(
      appBar: CustomAppBar(
        title: TimetableWidget.of(context).feature.name,
        loadingKeys: [
          TimetableKeys.timetable,
          substitutionPlanFeature.featureKey,
          Keys.tags
        ],
      ),
      body: CustomHero(
        tag: TimetableKeys.timetable,
        child: loader.hasLoadedData &&
                substitutionPlanFeature.loader.hasLoadedData &&
                loader.data.selection.isSet()
            ? Material(
                type: MaterialType.transparency,
                child: CustomGrid(
                  onRefresh: () async {
                    final results = [
                      await Static.tags.syncToServer(
                        context,
                        [TimetableWidget.of(context).feature],
                      ),
                      await loader.loadOnline(context, force: true),
                      await substitutionPlanFeature.loader
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
                  appendRowPrepend: [
                    Container(
                      height: 60,
                      child: Center(
                        child: Text(
                          'Termine',
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
                          'Cafétoria',
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
                    int count = 0;

                    // Check cafetoria
                    final cafetoria =
                        CafetoriaWidget.of(context)?.feature?.loader;
                    if (cafetoria != null && cafetoria.hasLoadedData) {
                      final days =
                          cafetoria.data.days.where((d) => d.date == day);
                      if (days.isNotEmpty && days.first.menus.isNotEmpty) {
                        count++;
                      }
                    }

                    // Check calendar
                    final calendar =
                        CalendarWidget.of(context)?.feature?.loader;
                    if (calendar != null &&
                        calendar.hasLoadedData &&
                        calendar.data.getEventsForDate(day).isNotEmpty) {
                      count++;
                    }
                    return count;
                  }),
                  extraInfoChildren: List.generate(5, (weekday) {
                    final day = _monday.add(Duration(days: weekday));
                    return [
                      if (CafetoriaWidget.of(context) != null)
                        CafetoriaInfoCard(
                          date: day,
                          showNavigation: false,
                          isSingleDay: true,
                        ),
                      if (CalendarWidget.of(context) != null)
                        CalendarInfoCard(
                          date: day,
                          showNavigation: false,
                          isSingleDay: true,
                        ),
                    ].map((x) => SizeLimit(child: x)).toList().cast<Widget>();
                  }),
                  children: List.generate(
                    5,
                    (weekday) => loader.data.days[weekday].units.map((unit) {
                      final day = _monday.add(Duration(days: weekday));
                      final subject = loader.data.selection
                          .getSelectedSubject(unit.subjects);
                      // ignore: omit_local_variable_types
                      final List<Substitution> substitutions =
                          subject?.getSubstitutions(
                                  day, substitutionPlanFeature.loader.data) ??
                              [];
                      return SizeLimit(
                        child: InkWell(
                          onTap: () async {
                            if (unit.subjects.length > 1) {
                              // ignore: omit_local_variable_types
                              final TimetableSubject selection =
                                  await showDialog(
                                context: context,
                                builder: (context) => TimetableSelectDialog(
                                  weekday: weekday,
                                  unit: unit,
                                ),
                              );
                              if (selection == null) {
                                return;
                              }
                              loader.data.selection.setSelectedSubject(
                                selection,
                                EventBus.of(context),
                                substitutionPlanFeature.loader.data,
                                loader.data,
                              );
                              setState(() {});
                              try {
                                await loader.data.selection.save(context);
                                if (mounted) {
                                  setState(() {});
                                }
                                // ignore: empty_catches
                              } on DioError {}
                            }
                          },
                          child: Container(
                            margin: EdgeInsets.all(10),
                            child: Column(
                              children: [
                                if (substitutions.isEmpty)
                                  TimetableRow(
                                    subject: subject ??
                                        TimetableSubject(
                                          unit: unit.unit,
                                          subjectID: 'none',
                                          teacherID: null,
                                          roomID: null,
                                          courseID: '',
                                          id: '',
                                          day: weekday,
                                          block: '',
                                        ),
                                    showUnit: getScreenSize(
                                            MediaQuery.of(context)
                                                .size
                                                .width) !=
                                        ScreenSize.big,
                                  ),
                                if (substitutions.isNotEmpty)
                                  SubstitutionList(
                                    padding: false,
                                    substitutions: substitutions
                                        .where((substitution) =>
                                            substitution.unit == subject.unit)
                                        .toList(),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              )
            : Center(child: EmptyList(title: 'Kein Stundenplan')),
      ),
    );
  }
}
