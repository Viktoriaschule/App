import 'package:flutter/material.dart';
import 'package:ginko/plugins/platform/platform.dart';
import 'package:ginko/substitution_plan/substitution_plan_row.dart';
import 'package:ginko/utils/bottom_navigation.dart';
import 'package:ginko/utils/custom_grid.dart';
import 'package:ginko/utils/empty_list.dart';
import 'package:ginko/utils/icons_texts.dart';
import 'package:ginko/utils/list_group.dart';
import 'package:ginko/utils/screen_sizes.dart';
import 'package:ginko/utils/size_limit.dart';
import 'package:ginko/utils/static.dart';
import 'package:ginko/utils/theme.dart';
import 'package:ginko/models/models.dart';
import 'package:timeago/timeago.dart' as timeago;

// ignore: public_member_api_docs
class SubstitutionPlanPage extends StatefulWidget {
  @override
  _SubstitutionPlanPageState createState() => _SubstitutionPlanPageState();
}

class _SubstitutionPlanPageState extends State<SubstitutionPlanPage> {
  @override
  Widget build(BuildContext context) => Column(
        children: <Widget>[
          Expanded(
            child: Static.timetable.hasLoadedData &&
                    Static.substitutionPlan.hasLoadedData
                ? CustomGrid(
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
                              color: textColor(context),
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
                              color: textColor(context),
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
                          myChanges = Static
                              .substitutionPlan.data.days[index].myChanges;
                          notMyChanges = Static
                              .substitutionPlan.data.days[index].otherChanges;
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
                          if (getScreenSize(
                                  MediaQuery.of(context).size.width) !=
                              ScreenSize.small)
                            myChangesWidget
                          else
                            ListGroup(
                              title: 'Meine Vertretungen',
                              children: [
                                myChangesWidget,
                              ],
                            ),
                          if (getScreenSize(
                                  MediaQuery.of(context).size.width) !=
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
                          Hero(
                            tag: Platform().isWeb
                                ? this
                                : getScreenSize(MediaQuery.of(context)
                                            .size
                                            .width) ==
                                        ScreenSize.small
                                    ? Keys.substitutionPlan
                                    : '${Keys.substitutionPlan}-$index',
                            child: Material(
                              type: MaterialType.transparency,
                              child: Center(
                                child: SizeLimit(
                                  child: Card(
                                    shape: BeveledRectangleBorder(
                                      borderRadius: BorderRadius.circular(0),
                                    ),
                                    elevation: 5,
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
                                            Static.substitutionPlan.data
                                                .days[index].updated,
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
          ),
          Hero(
            tag: !Platform().isWeb
                ? Keys.navigation(Keys.substitutionPlan)
                : hashCode,
            child: Material(
              type: MaterialType.transparency,
              child: BottomNavigation(
                actions: [
                  NavigationAction(Icons.expand_less, () {
                    Navigator.pop(context);
                  }),
                ],
              ),
            ),
          )
        ],
      );
}
