import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ginko/cafetoria/cafetoria_row.dart';
import 'package:ginko/calendar/calendar_row.dart';
import 'package:ginko/substitution_plan/substitution_plan_row.dart';
import 'package:ginko/timetable/timetable_row.dart';
import 'package:ginko/timetable/timetable_select_dialog.dart';
import 'package:ginko/utils/list_group_header.dart';
import 'package:ginko/utils/screen_sizes.dart';
import 'package:ginko/utils/size_limit.dart';
import 'package:ginko/utils/static.dart';
import 'package:ginko/utils/tab_proxy.dart';
import 'package:ginko/models/models.dart';

// ignore: public_member_api_docs
class TimetablePage extends StatefulWidget {
  @override
  _TimetablePageState createState() => _TimetablePageState();
}

class _TimetablePageState extends State<TimetablePage>
    with SingleTickerProviderStateMixin {
  TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(vsync: this, length: 5);
    if (Static.timetable.hasLoadedData) {
      _tabController.index =
          Static.timetable.data.initialDay(DateTime.now()).weekday - 1;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) => TabProxy(
        controller: _tabController,
        threshold: ScreenSize.big,
        weekdays: weekdays.values
            .toList()
            .sublist(0, 5)
            .map((weekday) =>
                getScreenSize(MediaQuery.of(context).size.width) ==
                        ScreenSize.small
                    ? weekday.substring(0, 2).toUpperCase()
                    : weekday)
            .toList(),
        tabs: List.generate(
          5,
          (weekday) {
            final events = Static.calendar.hasLoadedData
                ? (Static.calendar.data.getEventsForTimeSpan(
                        monday(DateTime.now()).add(Duration(days: weekday)),
                        monday(DateTime.now())
                            .add(Duration(days: weekday + 1))
                            .subtract(Duration(seconds: 1)))
                      ..sort((a, b) => a.start.compareTo(b.start)))
                    .toList()
                : [];
            final calendarView = Column(
              children: [
                if (Static.calendar.hasLoadedData)
                  ListGroupHeader(
                    title: 'Termine',
                    onTap: () {
                      Navigator.of(context).pushNamed('/${Keys.calendar}');
                    },
                  ),
                if (!Static.calendar.hasLoadedData || events.isEmpty)
                  Container(
                    height: 60,
                    color: Colors.transparent,
                  )
                else
                  SizeLimit(
                    child: Column(
                      children: [
                        ...events
                            .map((event) => Container(
                                  margin: EdgeInsets.all(10),
                                  child: CalendarRow(
                                    event: event,
                                  ),
                                ))
                            .toList()
                            .cast<Widget>(),
                      ],
                    ),
                  ),
              ],
            );
            final days = Static.cafetoria.hasLoadedData
                ? (Static.cafetoria.data.days
                        .where((d) =>
                            d.date ==
                            monday(DateTime.now()).add(Duration(days: weekday)))
                        .toList()
                          ..sort((a, b) => a.date.compareTo(b.date)))
                    .toList()
                : [];
            final cafetoriaView = Column(
              children: [
                if (Static.cafetoria.hasLoadedData)
                  ListGroupHeader(
                    title: 'Cafétoria',
                    onTap: () {
                      Navigator.of(context).pushNamed('/${Keys.cafetoria}');
                    },
                  ),
                if (!Static.cafetoria.hasLoadedData || days.isEmpty)
                  Container(
                    height: 60,
                    color: Colors.transparent,
                  )
                else
                  SizeLimit(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ...days
                            .map((day) => Column(
                                  children: day.menus
                                      .map(
                                        (menu) => Container(
                                          margin: EdgeInsets.all(10),
                                          child: CafetoriaRow(
                                            day: day,
                                            menu: menu,
                                          ),
                                        ),
                                      )
                                      .toList()
                                      .cast<Widget>(),
                                ))
                            .toList()
                            .cast<Widget>(),
                      ],
                    ),
                  ),
              ],
            );
            return Scrollbar(
              child: ListView(
                shrinkWrap: true,
                padding: EdgeInsets.only(top: 10, bottom: 10),
                children: [
                  if (Static.timetable.hasLoadedData &&
                      Static.substitutionPlan.hasLoadedData)
                    ...Static.timetable.data.days[weekday].units.map((unit) {
                      final subject =
                          Static.selection.getSelectedSubject(unit.subjects);
                      // ignore: omit_local_variable_types
                      final List<Substitution> substitutions =
                          subject.substitutions;
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
                              Static.selection.setSelectedSubject(selection);
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
                                          keepPadding: true,
                                        ))
                                    .toList()
                                    .cast<Widget>(),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  if (events.isNotEmpty || days.isNotEmpty)
                    Container(
                      height: 46,
                      color: Colors.transparent,
                    ),
                  if (events.isNotEmpty) calendarView,
                  if (days.isNotEmpty) cafetoriaView,
                ],
              ),
            );
          },
        ).toList().cast<Widget>(),
      );
}
