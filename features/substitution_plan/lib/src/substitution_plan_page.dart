import 'package:flutter/material.dart';
import 'package:flutter_event_bus/flutter_event_bus.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:utils/utils.dart';
import 'package:widgets/widgets.dart';

import 'substitution_list.dart';
import 'substitution_plan_model.dart';

// ignore: public_member_api_docs
class SubstitutionPlanPage extends StatefulWidget {
  // ignore: public_member_api_docs
  const SubstitutionPlanPage({
    Key key,
    this.day,
    this.grade,
  })  : assert(day == null || day == 0 || day == 1, 'day must be null, 0 or 1'),
        super(key: key);

  // ignore: public_member_api_docs
  final int day;

  // ignore: public_member_api_docs
  final String grade;

  @override
  _SubstitutionPlanPageState createState() => _SubstitutionPlanPageState();
}

class _SubstitutionPlanPageState extends Interactor<SubstitutionPlanPage> {
  @override
  Subscription subscribeEvents(EventBus eventBus) => eventBus
      .respond<TagsUpdateEvent>((event) => setState(() => null))
      .respond<SubstitutionPlanUpdateEvent>((event) => setState(() => null))
      .respond<TimetableUpdateEvent>((event) => setState(() => null));

  @override
  Widget build(BuildContext context) {
    int nearestDay = 0;
    if (Static.substitutionPlan.hasLoadedData &&
        Static.timetable.hasLoadedData) {
      final List<DateTime> dates =
          Static.substitutionPlan.data.days.map((e) => e.date).toList();
      final day = DateTime(
        dates[0].year,
        dates[0].month,
        dates[0].day,
      );
      final lessonCount =
          Static.timetable.data.days[day.weekday - 1].getUserLessonsCount();
      if (DateTime.now()
          .isAfter(day.add(Times.getUnitTimes(lessonCount - 1)[1]))) {
        nearestDay = 1;
      }
    }
    return Scaffold(
      appBar: CustomAppBar(
        title: Pages.of(context).pages[Keys.substitutionPlan].title,
        loadingKeys: [Keys.substitutionPlan, Keys.timetable, Keys.tags],
        actions: <Widget>[
          if (Static.user.grade != null &&
              Static.timetable.hasLoadedData &&
              Static.substitutionPlan.hasLoadedData)
            Container(
              width: 48,
              child: DropdownButton<String>(
                  underline: Container(),
                  value: widget.grade ?? Static.user.grade,
                  items: grades
                      .where(
                          (g) => widget.grade == null || g != Static.user.grade)
                      .map(
                        (grade) => DropdownMenuItem(
                          value: grade,
                          child: Text(
                            isSeniorGrade(grade) ? grade.toUpperCase() : grade,
                            style: TextStyle(fontWeight: FontWeight.w100),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (grade) {
                    if (grade != (widget.grade ?? Static.user.grade)) {
                      final route = MaterialPageRoute<void>(
                        builder: (context) => SubstitutionPlanPage(
                          grade: grade,
                        ),
                      );
                      if (widget.grade == null) {
                        Navigator.of(context).push(route);
                      } else {
                        Navigator.of(context).pushReplacement(route);
                      }
                    }
                  }),
            ),
        ],
      ),
      body: Static.timetable.hasLoadedData &&
              Static.substitutionPlan.hasLoadedData
          ? CustomGrid(
              onRefresh: () async => reduceStatusCodes([
                await Static.tags.syncTags(context),
                await Static.timetable.loadOnline(context, force: true),
                await Static.substitutionPlan.loadOnline(context, force: true),
              ]),
              initialHorizontalIndex: widget.day ?? nearestDay,
              type: getScreenSize(MediaQuery.of(context).size.width) ==
                      ScreenSize.small
                  ? CustomGridType.tabs
                  : CustomGridType.grid,
              columnPrepend: Static.substitutionPlan.data.days
                  .map((day) => weekdays[day.date.weekday - 1])
                  .toList(),
              childrenRowPrepend: [
                Container(
                  height: 60,
                  color: Colors.transparent,
                ),
                if (widget.grade == null)
                  Container(
                    height: 60,
                    child: Center(
                      child: Text(
                        'Meine Vertretungen',
                        style: TextStyle(
                          fontSize: 16,
                          color: ThemeWidget.of(context).textColor,
                        ),
                      ),
                    ),
                  ),
                if (widget.grade == null)
                  Container(
                    height: 60,
                    child: Center(
                      child: Text(
                        'Weitere Vertretungen',
                        style: TextStyle(
                          fontSize: 16,
                          color: ThemeWidget.of(context).textColor,
                        ),
                      ),
                    ),
                  ),
                if (widget.grade != null)
                  Container(
                    height: 60,
                    child: Center(
                      child: Text(
                        'Vertretungen',
                        style: TextStyle(
                          fontSize: 16,
                          color: ThemeWidget.of(context).textColor,
                        ),
                      ),
                    ),
                  ),
              ],
              children: List.generate(
                2,
                (index) {
                  List<Widget> items = [];
                  if (widget.grade == null) {
                    List<Substitution> myChanges = [];
                    List<Substitution> notMyChanges = [];
                    if (Static.substitutionPlan.hasLoadedData) {
                      myChanges =
                          Static.substitutionPlan.data.days[index].myChanges;
                      notMyChanges =
                          Static.substitutionPlan.data.days[index].otherChanges;
                    }
                    final myChangesWidget = myChanges.isEmpty
                        ? EmptyList(title: 'Keine Änderungen')
                        : SubstitutionList(substitutions: myChanges);
                    final notMyChangesWidget = notMyChanges.isEmpty
                        ? EmptyList(title: 'Keine Änderungen')
                        : SubstitutionList(substitutions: notMyChanges);
                    items = [
                      if (getScreenSize(MediaQuery.of(context).size.width) !=
                          ScreenSize.small)
                        myChangesWidget
                      else
                        ListGroup(
                          title: 'Meine Vertretungen',
                          children: [
                            Container(
                              margin: EdgeInsets.only(
                                left: 10,
                                right: 10,
                              ),
                              child: myChangesWidget,
                            ),
                          ],
                        ),
                      if (getScreenSize(MediaQuery.of(context).size.width) !=
                          ScreenSize.small)
                        notMyChangesWidget
                      else
                        ListGroup(
                          title: 'Weitere Vertretungen',
                          children: [
                            Container(
                              margin: EdgeInsets.only(
                                left: 10,
                                right: 10,
                              ),
                              child: notMyChangesWidget,
                            ),
                          ],
                        ),
                    ];
                  } else {
                    List<Substitution> changes = [];
                    if (Static.substitutionPlan.hasLoadedData) {
                      changes = Static
                          .substitutionPlan.data.days[index].data[widget.grade];
                    }
                    final changesWidget = changes.isEmpty
                        ? EmptyList(title: 'Keine Änderungen')
                        : SubstitutionList(substitutions: changes);
                    items = [
                      if (getScreenSize(MediaQuery.of(context).size.width) !=
                          ScreenSize.small)
                        changesWidget
                      else
                        ListGroup(
                          title: 'Vertretungen',
                          children: [
                            Container(
                              margin: EdgeInsets.only(
                                left: 10,
                                right: 10,
                              ),
                              child: changesWidget,
                            ),
                          ],
                        ),
                    ];
                  }
                  return [
                    CustomHero(
                      tag: getScreenSize(MediaQuery.of(context).size.width) ==
                              ScreenSize.small
                          ? Keys.substitutionPlan
                          : '${Keys.substitutionPlan}-$index',
                      child: Material(
                        type: MaterialType.transparency,
                        child: Center(
                          child: SizeLimit(
                            child: CustomCard(
                              margin: EdgeInsets.all(10),
                              child: Container(
                                margin: EdgeInsets.all(10),
                                child: IconsTexts(
                                  icons: [
                                    Icons.event,
                                    Icons.timer,
                                  ],
                                  texts: [
                                    outputDateFormat.format(Static
                                        .substitutionPlan
                                        .data
                                        .days[index]
                                        .date),
                                    timeago.format(
                                      Static.substitutionPlan.data.days[index]
                                          .updated,
                                      locale: 'de',
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    ...items,
                  ];
                },
              ),
            )
          : Center(child: EmptyList(title: 'Kein Vertretungsplan')),
    );
  }
}
