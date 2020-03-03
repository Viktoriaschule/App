import 'package:flutter/material.dart';
import 'package:flutter_event_bus/flutter_event_bus.dart';
import 'package:substitution_plan/src/substitution_plan_keys.dart';
import 'package:substitution_plan/substitution_plan.dart';
import 'package:utils/utils.dart';
import 'package:widgets/widgets.dart';

import 'substitution_list.dart';
import 'substitution_plan_model.dart';
import 'substitution_plan_page.dart';

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

  SubstitutionPlanDay getSpDay(SubstitutionPlan data) =>
      data?.getForDate(widget.date);

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
    final loader = SubstitutionPlanWidget.of(context).feature.loader;
    final substitutionPlanDay = getSpDay(loader.data);
    final substitutions = getSubstitutions(substitutionPlanDay);
    utils ??= InfoCardUtils(context, widget.date);
    return ListGroup(
      loadingKeys: const [SubstitutionPlanKeys.substitutionPlan],
      heroId: getScreenSize(MediaQuery.of(context).size.width) ==
              ScreenSize.small
          ? SubstitutionPlanKeys.substitutionPlan
          : '${SubstitutionPlanKeys.substitutionPlan}-${loader.data.days.indexOf(substitutionPlanDay)}',
      heroIdNavigation: SubstitutionPlanKeys.substitutionPlan,
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
                if (loader.hasLoadedData)
                  SubstitutionList(
                    substitutions: substitutions.length > utils.cut
                        ? substitutions.sublist(0, utils.cut)
                        : substitutions,
                  ),
              ],
            ),
          ),
      ],
    );
  }
}
