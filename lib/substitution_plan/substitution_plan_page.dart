import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ginko/substitution_plan/substitution_plan_row.dart';
import 'package:ginko/utils/icons_texts.dart';
import 'package:ginko/utils/list_group_header.dart';
import 'package:ginko/utils/screen_sizes.dart';
import 'package:ginko/utils/size_limit.dart';
import 'package:ginko/utils/static.dart';
import 'package:ginko/utils/tab_proxy.dart';
import 'package:ginko/models/models.dart';
import 'package:timeago/timeago.dart' as timeago;

// ignore: public_member_api_docs
class SubstitutionPlanPage extends StatefulWidget {
  @override
  _SubstitutionPlanPageState createState() => _SubstitutionPlanPageState();
}

class _SubstitutionPlanPageState extends State<SubstitutionPlanPage>
    with SingleTickerProviderStateMixin {
  TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(vsync: this, length: 2);
    super.initState();
  }

  @override
  Widget build(BuildContext context) => TabProxy(
        controller: _tabController,
        weekdays: [
          if (Static.substitutionPlan.hasLoadedData)
            ...Static.substitutionPlan.data.days
                .map((day) => weekdays[day.date.weekday - 1])
                .toList()
          else ...['', ''],
        ]
            .cast<String>()
            .map((weekday) =>
                getScreenSize(MediaQuery.of(context).size.width) ==
                            ScreenSize.small &&
                        weekday.isNotEmpty
                    ? weekday.substring(0, 2).toUpperCase()
                    : weekday)
            .toList(),
        tabs: List.generate(
          2,
          (index) {
            List<Substitution> myChanges = [];
            List<Substitution> notMyChanges = [];
            if (Static.substitutionPlan.hasLoadedData) {
              myChanges = Static.substitutionPlan.data.days[index].myChanges;
              notMyChanges =
                  Static.substitutionPlan.data.days[index].otherChanges;
            }

            final items = [
              ListGroupHeader(
                title: 'Meine Vertretungen',
              ),
              if (myChanges.isEmpty)
                Container(
                  height: 60,
                  color: Colors.transparent,
                )
              else
                ...myChanges
                    .map((substitution) => SizeLimit(
                          child: Container(
                            margin: EdgeInsets.all(10),
                            child: SubstitutionPlanRow(
                              substitution: substitution,
                            ),
                          ),
                        ))
                    .toList()
                    .cast<Widget>(),
              if (Static
                  .substitutionPlan.data.days[index].myUnparsed.isNotEmpty) ...[
                ListGroupHeader(
                  title: 'Nicht erkannt',
                ),
                ...Static.substitutionPlan.data.days[index].myUnparsed
                    .map((unparsed) => Padding(
                          padding: EdgeInsets.all(20),
                          child: Text(unparsed),
                        ))
                    .toList()
              ],
              ListGroupHeader(
                title: 'Weitere Vertretungen',
              ),
              ...notMyChanges
                  .map((substitution) => SizeLimit(
                        child: Container(
                          margin: EdgeInsets.all(10),
                          child: SubstitutionPlanRow(
                            substitution: substitution,
                          ),
                        ),
                      ))
                  .toList()
                  .cast<Widget>(),
            ];
            return Scrollbar(
              child: ListView(
                shrinkWrap: true,
                children: [
                  if (Static.substitutionPlan.hasLoadedData)
                    Column(
                      children: [
                        Container(
                          margin: EdgeInsets.all(10),
                          child: IconsTexts(
                            icons: [
                              Icons.timer,
                              Icons.event,
                            ],
                            texts: [
                              timeago.format(
                                Static
                                    .substitutionPlan.data.days[index].updated,
                                locale: 'de',
                              ),
                              outputDateFormat.format(Static
                                  .substitutionPlan.data.days[index].date),
                            ],
                          ),
                        ),
                        ...items,
                      ],
                    ),
                ],
              ),
            );
          },
        ),
      );
}
