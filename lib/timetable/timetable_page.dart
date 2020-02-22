import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_event_bus/flutter_event_bus.dart';
import 'package:viktoriaapp/app/app_page.dart';
import 'package:viktoriaapp/cafetoria/cafetoria_info_card.dart';
import 'package:viktoriaapp/calendar/calendar_info_card.dart';
import 'package:viktoriaapp/models/models.dart';
import 'package:viktoriaapp/substitution_plan/substitution_plan_row.dart';
import 'package:viktoriaapp/timetable/timetable_row.dart';
import 'package:viktoriaapp/timetable/timetable_select_dialog.dart';
import 'package:viktoriaapp/utils/events.dart';
import 'package:viktoriaapp/utils/screen_sizes.dart';
import 'package:viktoriaapp/utils/static.dart';
import 'package:viktoriaapp/utils/theme.dart';
import 'package:viktoriaapp/widgets/custom_grid.dart';
import 'package:viktoriaapp/widgets/custom_hero.dart';
import 'package:viktoriaapp/widgets/size_limit.dart';

// ignore: public_member_api_docs
class TimetablePage extends StatefulWidget {
  // ignore: public_member_api_docs
  const TimetablePage({
    @required this.pages,
    Key key,
  }) : super(key: key);

  // ignore: public_member_api_docs
  final Map<String, InlinePage> pages;

  @override
  _TimetablePageState createState() => _TimetablePageState();
}

class _TimetablePageState extends State<TimetablePage> {
  @override
  Widget build(BuildContext context) => CustomHero(
        tag: Keys.timetable,
        child: Static.timetable.hasLoadedData &&
                Static.substitutionPlan.hasLoadedData &&
                Static.cafetoria.hasLoadedData &&
                Static.calendar.hasLoadedData &&
                Static.selection.isSet()
            ? Material(
                type: MaterialType.transparency,
                child: CustomGrid(
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
                            color: textColor(context),
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
                            color: textColor(context),
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
                            color: textColor(context),
                          ),
                        ),
                      ),
                    ),
                  ],
                  append: List.generate(5, (weekday) {
                    final day =
                        monday(DateTime.now()).add(Duration(days: weekday));
                    final cafetoriaView = Static.cafetoria.hasLoadedData
                        ? CafetoriaInfoCard(
                            date: day,
                            pages: widget.pages,
                            showNavigation: false,
                            isSingleDay: true,
                          )
                        : Container();
                    final calendarView = Static.calendar.hasLoadedData
                        ? CalendarInfoCard(
                            date: day,
                            pages: widget.pages,
                            showNavigation: false,
                            isSingleDay: true,
                          )
                        : Container();
                    return [
                      calendarView,
                      cafetoriaView,
                    ].map((x) => SizeLimit(child: x)).toList().cast<Widget>();
                  }),
                  children: List.generate(
                    5,
                    (weekday) =>
                        Static.timetable.data.days[weekday].units.map((unit) {
                      final subject =
                          Static.selection.getSelectedSubject(unit.subjects);
                      // ignore: omit_local_variable_types
                      final List<Substitution> substitutions =
                          subject?.substitutions ?? [];
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
                                          MediaQuery.of(context).size.width) !=
                                      ScreenSize.big,
                                ),
                                ...substitutions
                                    .map((substitution) => SubstitutionPlanRow(
                                          substitution: substitution,
                                          showUnit: false,
                                          keepPadding: getScreenSize(
                                                  MediaQuery.of(context)
                                                      .size
                                                      .width) !=
                                              ScreenSize.big,
                                        ))
                                    .toList()
                                    .cast<Widget>(),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              )
            : Container(),
      );
}
