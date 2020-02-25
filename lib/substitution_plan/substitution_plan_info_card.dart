import 'package:flutter/material.dart';
import 'package:flutter_event_bus/flutter_event_bus.dart';
import 'package:viktoriaapp/models/models.dart';
import 'package:viktoriaapp/substitution_plan/substitution_plan_page.dart';
import 'package:viktoriaapp/substitution_plan/substitution_plan_row.dart';
import 'package:viktoriaapp/utils/events.dart';
import 'package:viktoriaapp/utils/info_card.dart';
import 'package:viktoriaapp/utils/screen_sizes.dart';
import 'package:viktoriaapp/utils/static.dart';
import 'package:viktoriaapp/widgets/custom_bottom_navigation.dart';
import 'package:viktoriaapp/widgets/empty_list.dart';
import 'package:viktoriaapp/widgets/list_group.dart';
import 'package:viktoriaapp/widgets/size_limit.dart';

// ignore: public_member_api_docs
class SubstitutionPlanInfoCard extends StatefulWidget {
  // ignore: public_member_api_docs
  const SubstitutionPlanInfoCard({
    @required this.date,
    Key key,
  }) : super(key: key);

  // ignore: public_member_api_docs
  final DateTime date;

  @override
  _SubstitutionPlanInfoCardState createState() =>
      _SubstitutionPlanInfoCardState();
}

class _SubstitutionPlanInfoCardState
    extends Interactor<SubstitutionPlanInfoCard> {
  InfoCardUtils utils;

  SubstitutionPlanDay getSpDay() =>
      Static.substitutionPlan.data?.getForDate(widget.date);

  List<Substitution> getSubstitutions(SubstitutionPlanDay spDay) =>
      spDay?.myChanges ?? [];

  @override
  Subscription subscribeEvents(EventBus eventBus) => eventBus
      .respond<TagsUpdateEvent>(update)
      .respond<TimetableUpdateEvent>(update)
      .respond<SubstitutionPlanUpdateEvent>(update);

  // ignore: type_annotate_public_apis
  void update(event) => setState(() => null);

  @override
  Widget build(BuildContext context) {
    final substitutionPlanDay = getSpDay();
    final substitutions = getSubstitutions(substitutionPlanDay);
    utils ??= InfoCardUtils(context, widget.date);
    return ListGroup(
      loadingKeys: [Keys.substitutionPlan],
      heroId: getScreenSize(MediaQuery.of(context).size.width) ==
              ScreenSize.small
          ? Keys.substitutionPlan
          : '${Keys.substitutionPlan}-${Static.substitutionPlan.data.days.indexOf(substitutionPlanDay)}',
      heroIdNavigation: Keys.substitutionPlan,
      title: 'Nächste Vertretungen - ${weekdays[widget.date.weekday - 1]}',
      counter: substitutions.length > utils.cut
          ? substitutions.length - utils.cut
          : 0,
      actions: [
        NavigationAction(Icons.expand_more, () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (context) => SubstitutionPlanPage(),
            ),
          );
        }),
      ],
      children: [
        if (substitutions.isEmpty)
          EmptyList(title: 'Keine Änderungen')
        else
          SizeLimit(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (Static.substitutionPlan.hasLoadedData)
                  ...(substitutions.length > utils.cut
                          ? substitutions.sublist(0, utils.cut)
                          : substitutions)
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
