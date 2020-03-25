import 'package:flutter/material.dart';
import 'package:flutter_event_bus/flutter_event_bus.dart';
import 'package:substitution_plan/substitution_plan.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:timetable/timetable.dart';
import 'package:utils/utils.dart';
import 'package:widgets/widgets.dart';

import 'substitution_plan_events.dart';
import 'substitution_plan_model.dart';

// ignore: public_member_api_docs
class SubstitutionPlanPage extends StatefulWidget {
  // ignore: public_member_api_docs
  const SubstitutionPlanPage({
    Key key,
    this.day,
    this.group,
  })  : assert(day == null || day == 0 || day == 1, 'day must be null, 0 or 1'),
        super(key: key);

  // ignore: public_member_api_docs
  final int day;

  // ignore: public_member_api_docs
  final String group;

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
    final loader = SubstitutionPlanWidget.of(context).feature.loader;
    final timetableLoader = TimetableWidget.of(context).feature.loader;
    int nearestDay = 0;
    if (loader.hasLoadedData && timetableLoader.hasLoadedData) {
      final List<DateTime> dates = loader.data.days.map((e) => e.date).toList();
      final day = DateTime(
        dates[0].year,
        dates[0].month,
        dates[0].day,
      );
      final lessonCount = timetableLoader.data.days[day.weekday - 1]
          .getUserLessonsCount(timetableLoader.data.selection);
      if (DateTime.now()
          .isAfter(day.add(Times.getUnitTimes(lessonCount - 1)[1]))) {
        nearestDay = 1;
      }
    }
    return Scaffold(
      appBar: CustomAppBar(
        title: SubstitutionPlanLocalizations.name,
        loadingKeys: [
          SubstitutionPlanKeys.substitutionPlan,
          TimetableWidget.of(context).feature.featureKey,
          Keys.tags
        ],
        actions: <Widget>[
          if (Static.user.group != null &&
              timetableLoader.hasLoadedData &&
              loader.hasLoadedData &&
              !Static.user.isTeacher())
            Container(
              width: 48,
              child: DropdownButton<String>(
                  underline: Container(),
                  value: widget.group ?? Static.user.group,
                  items: grades
                      .where(
                          (g) => widget.group == null || g != Static.user.group)
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
                    if (grade != (widget.group ?? Static.user.group)) {
                      final route = MaterialPageRoute<void>(
                        builder: (context) =>
                            SubstitutionPlanPage(
                              group: grade,
                            ),
                      );
                      if (widget.group == null) {
                        Navigator.of(context).push(route);
                      } else {
                        Navigator.of(context).pushReplacement(route);
                      }
                    }
                  }),
            ),
        ],
      ),
      body: timetableLoader.hasLoadedData && loader.hasLoadedData
          ? CustomGrid(
              onRefresh: () async => reduceStatusCodes([
                await Static.tags.syncToServer(
                  context,
                  [SubstitutionPlanWidget.of(context).feature],
                ),
                await timetableLoader.loadOnline(context, force: true),
                await loader.loadOnline(context, force: true),
              ]),
              initialHorizontalIndex: widget.day ?? nearestDay,
              type: getScreenSize(MediaQuery.of(context).size.width) ==
                      ScreenSize.small
                  ? CustomGridType.tabs
                  : CustomGridType.grid,
              columnPrepend: loader.data.days
                  .map((day) => weekdays[day.date.weekday - 1])
                  .toList(),
              childrenRowPrepend: [
                Container(
                  height: 60,
                  color: Colors.transparent,
                ),
                if (widget.group == null)
                  Container(
                    height: 60,
                    child: Center(
                      child: Text(
                        SubstitutionPlanLocalizations.mySubstitutions,
                        style: TextStyle(
                          fontSize: 16,
                          color: ThemeWidget
                              .of(context)
                              .textColor,
                        ),
                      ),
                    ),
                  ),
                if (widget.group == null)
                  Container(
                    height: 60,
                    child: Center(
                      child: Text(
                        SubstitutionPlanLocalizations.otherSubstitutions,
                        style: TextStyle(
                          fontSize: 16,
                          color: ThemeWidget
                              .of(context)
                              .textColor,
                        ),
                      ),
                    ),
                  ),
                if (widget.group != null)
                  Container(
                    height: 60,
                    child: Center(
                      child: Text(
                        SubstitutionPlanLocalizations.substitutions,
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
              children: List.generate(
                2,
                (index) {
                  List<Widget> items = [];
                  if (widget.group == null) {
                    List<Substitution> myChanges = [];
                    List<Substitution> notMyChanges = [];
                    List<Substitution> undefinedChanges = [];
                    if (loader.hasLoadedData) {
                      myChanges = loader.data.days[index].myChanges;
                      notMyChanges = loader.data.days[index].otherChanges;
                      undefinedChanges =
                          loader.data.days[index].undefinedChanges;
                    }
                    final myChangesWidget = myChanges.isEmpty
                        ? [
                      EmptyList(
                        title:
                        SubstitutionPlanLocalizations.noSubstitutions,
                      )
                    ]
                        : getSubstitutionList(myChanges);
                    final notMyChangesWidget = notMyChanges.isEmpty
                        ? [
                      EmptyList(
                        title:
                        SubstitutionPlanLocalizations.noSubstitutions,
                      )
                    ]
                        : getSubstitutionList(notMyChanges);
                    final undefinedChangesWidget = undefinedChanges.isEmpty
                        ? null
                        : getSubstitutionList(undefinedChanges);
                    items = [
                      if (getScreenSize(MediaQuery
                          .of(context)
                          .size
                          .width) !=
                          ScreenSize.small)
                        Container(
                          margin: EdgeInsets.only(
                            right: 10,
                          ),
                          child: Column(children: myChangesWidget),
                        )
                      else
                        ListGroup(
                          title: SubstitutionPlanLocalizations.mySubstitutions,
                          children: myChangesWidget,
                        ),
                      if (undefinedChangesWidget != null &&
                          getScreenSize(MediaQuery
                              .of(context)
                              .size
                              .width) !=
                              ScreenSize.small)
                        Container(
                          margin: EdgeInsets.only(
                            right: 10,
                          ),
                          child: Column(children: undefinedChangesWidget),
                        )
                      else
                        if (undefinedChangesWidget != null)
                          ListGroup(
                            title: SubstitutionPlanLocalizations
                                .undefinedSubstitutions,
                            children: undefinedChangesWidget,
                          ),
                      if (getScreenSize(MediaQuery
                          .of(context)
                          .size
                          .width) !=
                          ScreenSize.small)
                        Container(
                          margin: EdgeInsets.only(
                            right: 10,
                          ),
                          child: Column(children: notMyChangesWidget),
                        )
                      else
                        ListGroup(
                          title:
                          SubstitutionPlanLocalizations.otherSubstitutions,
                          children: notMyChangesWidget,
                        ),
                    ];
                  } else {
                    List<Substitution> changes = [];
                    if (loader.hasLoadedData) {
                      changes = loader.data.days[index].data[widget.group];
                    }
                    final changesWidget = changes.isEmpty
                        ? [
                      EmptyList(
                        title:
                        SubstitutionPlanLocalizations.noSubstitutions,
                      )
                    ]
                        : getSubstitutionList(changes);
                    items = [
                      if (getScreenSize(MediaQuery
                          .of(context)
                          .size
                          .width) !=
                          ScreenSize.small)
                        Column(children: changesWidget)
                      else
                      //TODO: EdgeInsets.only(
                      //    left: 10,
                      //    right: 10,
                      //)
                        ListGroup(
                          title: SubstitutionPlanLocalizations.substitutions,
                          children: changesWidget,
                        ),
                    ];
                  }
                  return [
                    CustomHero(
                      tag: getScreenSize(MediaQuery.of(context).size.width) ==
                              ScreenSize.small
                          ? SubstitutionPlanKeys.substitutionPlan
                          : '${SubstitutionPlanKeys.substitutionPlan}-$index',
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
                                    shortOutputDateFormat
                                        .format(loader.data.days[index].date),
                                    timeago.format(
                                      loader.data.days[index].updated,
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
          : Center(
              child: EmptyList(
                title: SubstitutionPlanLocalizations.noSubstitutionPlan,
              ),
            ),
    );
  }
}
