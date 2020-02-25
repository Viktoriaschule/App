import 'package:flutter/material.dart';
import 'package:flutter_event_bus/flutter_event_bus.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:viktoriaapp/models/models.dart';
import 'package:viktoriaapp/substitution_plan/substitution_plan_row.dart';
import 'package:viktoriaapp/utils/events.dart';
import 'package:viktoriaapp/utils/pages.dart';
import 'package:viktoriaapp/utils/screen_sizes.dart';
import 'package:viktoriaapp/utils/static.dart';
import 'package:viktoriaapp/utils/theme.dart';
import 'package:viktoriaapp/widgets/custom_app_bar.dart';
import 'package:viktoriaapp/widgets/custom_card.dart';
import 'package:viktoriaapp/widgets/custom_grid.dart';
import 'package:viktoriaapp/widgets/custom_hero.dart';
import 'package:viktoriaapp/widgets/empty_list.dart';
import 'package:viktoriaapp/widgets/icons_texts.dart';
import 'package:viktoriaapp/widgets/list_group.dart';
import 'package:viktoriaapp/widgets/size_limit.dart';

// ignore: public_member_api_docs
class SubstitutionPlanPage extends StatefulWidget {
  // ignore: public_member_api_docs
  const SubstitutionPlanPage({
    Key key,
    this.day,
  })  : assert(day == null || day == 0 || day == 1, 'day must be null, 0 or 1'),
        super(key: key);

  // ignore: public_member_api_docs
  final int day;

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
      final List<int> diff = dates
          .map((e) => (e.millisecondsSinceEpoch -
                  monday(DateTime.now())
                      .add(Duration(days: DateTime.now().weekday - 1))
                      .millisecondsSinceEpoch)
              .abs())
          .toList();
      if (diff[1] < diff[0]) {
        nearestDay = 1;
      }
      if (nearestDay == 0) {
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
    }
    return Scaffold(
      appBar: CustomAppBar(
        title: Pages.of(context).pages[Keys.substitutionPlan].title,
        loadingKeys: [Keys.substitutionPlan, Keys.timetable, Keys.tags],
        actions: <Widget>[
          if (Static.user.grade != null)
            InkWell(
              onTap: () {},
              child: Container(
                width: 48,
                child: Center(
                  child: Container(
                    padding: EdgeInsets.all(7.5),
                    decoration: BoxDecoration(
                      boxShadow:
                          ThemeWidget.of(context).brightness == Brightness.light
                              ? [
                                  BoxShadow(
                                    color: Color(0xFFC8C8C8),
                                    spreadRadius: 0.5,
                                    blurRadius: 1,
                                  ),
                                ]
                              : null,
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.all(Radius.circular(24)),
                      border: Border.all(
                        color: ThemeWidget.of(context).textColor,
                        width:
                            getScreenSize(MediaQuery.of(context).size.width) ==
                                    ScreenSize.small
                                ? 0.5
                                : 1.25,
                      ),
                    ),
                    child: Text(
                      isSeniorGrade(Static.user.grade)
                          ? Static.user.grade.toUpperCase()
                          : Static.user.grade,
                      style: TextStyle(
                        fontSize: 22,
                        color: ThemeWidget.of(context).textColor,
                        fontFamily: 'RobotoMono',
                      ),
                    ),
                  ),
                ),
              ),
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
              ],
              children: List.generate(
                2,
                (index) {
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
                      : Column(
                          children: [
                            ...myChanges
                                .map((change) => SizeLimit(
                                      child: Container(
                                        margin: EdgeInsets.all(10),
                                        child: SubstitutionPlanRow(
                                          substitution: change,
                                        ),
                                      ),
                                    ))
                                .toList()
                                .cast<Widget>(),
                          ],
                        );
                  final notMyChangesWidget = notMyChanges.isEmpty
                      ? EmptyList(title: 'Keine Änderungen')
                      : Column(
                          children: [
                            ...notMyChanges
                                .map((change) => SizeLimit(
                                      child: Container(
                                        margin: EdgeInsets.all(10),
                                        child: SubstitutionPlanRow(
                                          substitution: change,
                                        ),
                                      ),
                                    ))
                                .toList()
                                .cast<Widget>(),
                          ],
                        );
                  final items = [
                    if (getScreenSize(MediaQuery.of(context).size.width) !=
                        ScreenSize.small)
                      myChangesWidget
                    else
                      ListGroup(
                        title: 'Meine Vertretungen',
                        children: [
                          myChangesWidget,
                        ],
                      ),
                    if (getScreenSize(MediaQuery.of(context).size.width) !=
                        ScreenSize.small)
                      notMyChangesWidget
                    else
                      ListGroup(
                        title: 'Weitere Vertretungen',
                        children: [
                          notMyChangesWidget,
                        ],
                      ),
                  ];
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
          : Container(),
    );
  }
}
