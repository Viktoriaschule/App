import 'package:flutter/material.dart';
import 'package:viktoriaapp/app/app_page.dart';
import 'package:viktoriaapp/models/models.dart';
import 'package:viktoriaapp/substitution_plan/substitution_plan_row.dart';
import 'package:viktoriaapp/utils/screen_sizes.dart';
import 'package:viktoriaapp/utils/static.dart';
import 'package:viktoriaapp/widgets/custom_app_bar.dart';
import 'package:viktoriaapp/widgets/custom_bottom_navigation.dart';
import 'package:viktoriaapp/widgets/empty_list.dart';
import 'package:viktoriaapp/utils/info_card.dart';
import 'package:viktoriaapp/widgets/list_group.dart';
import 'package:viktoriaapp/widgets/size_limit.dart';

// ignore: public_member_api_docs
class SubstitutionPlanInfoCard extends StatefulWidget {
  // ignore: public_member_api_docs
  const SubstitutionPlanInfoCard({
    @required this.date,
    @required this.pages,
    @required this.changes,
    @required this.substitutionPlanDay,
    Key key,
  }) : super(key: key);

  // ignore: public_member_api_docs
  final DateTime date;

  // ignore: public_member_api_docs
  final Map<String, InlinePage> pages;

  // ignore: public_member_api_docs
  final List<Substitution> changes;

  // ignore: public_member_api_docs
  final SubstitutionPlanDay substitutionPlanDay;

  @override
  _SubstitutionPlanInfoCardState createState() =>
      _SubstitutionPlanInfoCardState();
}

class _SubstitutionPlanInfoCardState extends State<SubstitutionPlanInfoCard> {
  InfoCardUtils utils;

  @override
  Widget build(BuildContext context) {
    utils ??= InfoCardUtils(context, widget.date);
    return ListGroup(
      heroId: getScreenSize(MediaQuery.of(context).size.width) ==
              ScreenSize.small
          ? Keys.substitutionPlan
          : '${Keys.substitutionPlan}-${Static.substitutionPlan.data.days.indexOf(widget.substitutionPlanDay)}',
      heroIdNavigation: Keys.substitutionPlan,
      title:
          'Nächste Vertretungen - ${weekdays[Static.timetable.data.initialDay(DateTime.now()).weekday - 1]}',
      counter: widget.changes.length > utils.cut
          ? widget.changes.length - utils.cut
          : 0,
      actions: [
        NavigationAction(Icons.expand_more, () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (context) => Scaffold(
                appBar: CustomAppBar(
                  title: widget.pages[Keys.substitutionPlan].title,
                  actions: widget.pages[Keys.substitutionPlan].actions,
                ),
                body: widget.pages[Keys.substitutionPlan].content,
              ),
            ),
          );
        }),
      ],
      children: [
        if (widget.changes.isEmpty)
          EmptyList(title: 'Keine Änderungen')
        else
          SizeLimit(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (Static.substitutionPlan.hasLoadedData)
                  ...(widget.changes.length > utils.cut
                          ? widget.changes.sublist(0, utils.cut)
                          : widget.changes)
                      .map((substitution) => Container(
                            margin: EdgeInsets.all(10),
                            child: SubstitutionPlanRow(
                              substitution: substitution,
                            ),
                          ))
                      .toList()
                      .cast<Widget>()
              ],
            ),
          ),
      ],
    );
  }
}
