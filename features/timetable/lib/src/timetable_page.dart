import 'package:cafetoria/cafetoria.dart';
import 'package:calendar/calendar.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_event_bus/flutter_event_bus.dart';
import 'package:substitution_plan/substitution_plan.dart';
import 'package:utils/utils.dart';
import 'package:widgets/widgets.dart';

import 'timetable_model.dart';
import 'timetable_row.dart';
import 'timetable_select_dialog.dart';

// ignore: public_member_api_docs
class TimetablePage extends StatefulWidget {
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
    final _monday = monday(Static.timetable.hasLoadedData
        ? Static.timetable.data.initialDay(DateTime.now())
        : DateTime.now());
    return Scaffold(
      appBar: CustomAppBar(
        title: Pages.of(context).pages[Keys.timetable].title,
        loadingKeys: [Keys.timetable, Keys.substitutionPlan, Keys.tags],
      ),
      body: CustomHero(
        tag: Keys.timetable,
        child: Static.timetable.hasLoadedData &&
                Static.substitutionPlan.hasLoadedData &&
                Static.selection.isSet()
            ? Material(
                type: MaterialType.transparency,
                child: CustomGrid(
                  onRefresh: () async {
                    final results = [
                      await Static.tags.syncTags(context),
                      await Static.timetable.loadOnline(context, force: true),
                      await Static.substitutionPlan
                          .loadOnline(context, force: true),
                    ];
                    return reduceStatusCodes(results);
                  },
                  initialHorizontalIndex:
                      Static.timetable.data.initialDay(DateTime.now()).weekday -
                          1,
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
                  append: List.generate(5, (weekday) {
                    final day = _monday.add(Duration(days: weekday));
                    final cafetoriaView = CafetoriaInfoCard(
                      date: day,
                      showNavigation: false,
                      isSingleDay: true,
                    );
                    final calendarView = CalendarInfoCard(
                      date: day,
                      showNavigation: false,
                      isSingleDay: true,
                    );
                    return [
                      calendarView,
                      cafetoriaView,
                    ].map((x) => SizeLimit(child: x)).toList().cast<Widget>();
                  }),
                  children: List.generate(
                    5,
                    (weekday) =>
                        Static.timetable.data.days[weekday].units.map((unit) {
                      final day = _monday.add(Duration(days: weekday));
                      final subject =
                          Static.selection.getSelectedSubject(unit.subjects);
                      // ignore: omit_local_variable_types
                      final List<Substitution> substitutions =
                          subject?.getSubstitutions(day) ?? [];
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
                              Static.selection
                                  .setSelectedSubject(selection, context);
                              setState(() {});
                              try {
                                await Static.selection.save(context);
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
