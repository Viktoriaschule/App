import 'package:flutter/material.dart';
import 'package:flutter_event_bus/flutter_event_bus.dart';
import 'package:viktoriaapp/models/models.dart';
import 'package:viktoriaapp/substitution_plan/substitution_plan_page.dart';
import 'package:viktoriaapp/substitution_plan/substitution_plan_row.dart';
import 'package:viktoriaapp/utils/events.dart';
import 'package:viktoriaapp/utils/screen_sizes.dart';
import 'package:viktoriaapp/utils/pages.dart';
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

  List<Substitution> _substitutions;
  SubstitutionPlanDay _substitutionPlanDay;

  SubstitutionPlanDay getSpDay() =>
      Static.substitutionPlan.data?.getForDate(widget.date);

  List<Substitution> getSubstitutions() =>
      _substitutionPlanDay?.myChanges ?? [];

  @override
  void initState() {
    _substitutionPlanDay = getSpDay();
    _substitutions = getSubstitutions();
    super.initState();
  }

  @override
  Subscription subscribeEvents(EventBus eventBus) => eventBus
      .respond<TimetableUpdateEvent>(update)
      .respond<SubstitutionPlanUpdateEvent>(update);

  // ignore: type_annotate_public_apis
  void update(event) => setState(() {
        _substitutionPlanDay = getSpDay();
        _substitutions = getSubstitutions();
      });

  @override
  Widget build(BuildContext context) {
    utils ??= InfoCardUtils(context, widget.date);
    return ListGroup(
      heroId: getScreenSize(MediaQuery.of(context).size.width) ==
              ScreenSize.small
          ? Keys.substitutionPlan
          : '${Keys.substitutionPlan}-${Static.substitutionPlan.data.days.indexOf(_substitutionPlanDay)}',
      heroIdNavigation: Keys.substitutionPlan,
      title:
          'Nächste Vertretungen - ${weekdays[Static.timetable.data.initialDay(DateTime.now()).weekday - 1]}',
      counter: _substitutions.length > utils.cut
          ? _substitutions.length - utils.cut
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
        if (_substitutions.isEmpty)
          EmptyList(title: 'Keine Änderungen')
        else
          SizeLimit(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (Static.substitutionPlan.hasLoadedData)
                  ...(_substitutions.length > utils.cut
                          ? _substitutions.sublist(0, utils.cut)
                          : _substitutions)
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
