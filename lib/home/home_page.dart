import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:viktoriaapp/aixformation/aixformation_info_card.dart';
import 'package:viktoriaapp/cafetoria/cafetoria_info_card.dart';
import 'package:viktoriaapp/calendar/calendar_info_card.dart';
import 'package:viktoriaapp/models/models.dart';
import 'package:viktoriaapp/substitution_plan/substitution_plan_info_card.dart';
import 'package:viktoriaapp/timetable/timetable_info_card.dart';
import 'package:viktoriaapp/utils/screen_sizes.dart';
import 'package:viktoriaapp/utils/static.dart';

// ignore: public_member_api_docs
class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final size = getScreenSize(MediaQuery.of(context).size.width);

    // Get the date for the home page
    final day = Static.selection.isSet() && Static.timetable.hasLoadedData
        ? Static.timetable.data.initialDay(DateTime.now())
        : monday(DateTime.now()).add(Duration(
            days: (DateTime.now().weekday > 5 ? 1 : DateTime.now().weekday) - 1,
          ));

    final widgetBuilders = [
      () => TimetableInfoCard(date: day),
      () => SubstitutionPlanInfoCard(date: day),
      () => CalendarInfoCard(date: day),
      () => CafetoriaInfoCard(date: day),
      () => AiXformationInfoCard(date: day),
    ];

    if (size == ScreenSize.small) {
      return Container(
        color: Theme.of(context).backgroundColor,
        child: ListView.builder(
          padding: EdgeInsets.only(bottom: 10),
          itemCount: widgetBuilders.length,
          itemBuilder: (context, index) => widgetBuilders[index](),
        ),
      );
    }
    if (size == ScreenSize.middle) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              widgetBuilders[1](),
              widgetBuilders[0](),
            ]
                .map((x) => Expanded(
                      flex: 1,
                      child: SizedBox(
                        height: (MediaQuery.of(context).size.height -
                                _screenPadding) /
                            3,
                        child: x,
                      ),
                    ))
                .toList()
                .cast<Widget>(),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              widgetBuilders[4](),
              widgetBuilders[3](),
            ]
                .map((x) => Expanded(
                      flex: 1,
                      child: SizedBox(
                        height: (MediaQuery.of(context).size.height -
                                _screenPadding) /
                            3,
                        child: x,
                      ),
                    ))
                .toList()
                .cast<Widget>(),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              widgetBuilders[2](),
            ]
                .map((x) => Expanded(
                      flex: 1,
                      child: SizedBox(
                        height: (MediaQuery.of(context).size.height -
                                _screenPadding) /
                            3,
                        child: x,
                      ),
                    ))
                .toList()
                .cast<Widget>(),
          ),
        ],
      );
    }
    if (size == ScreenSize.big) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              widgetBuilders[1](),
              widgetBuilders[3](),
            ]
                .map((x) => SizedBox(
                      height: (MediaQuery.of(context).size.height -
                              _screenPadding) /
                          2,
                      child: x,
                    ))
                .toList()
                .cast<Widget>(),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              widgetBuilders[0](),
              widgetBuilders[4](),
            ]
                .map((x) => SizedBox(
                      height: (MediaQuery.of(context).size.height -
                              _screenPadding) /
                          2,
                      child: x,
                    ))
                .toList()
                .cast<Widget>(),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height - _screenPadding,
            child: widgetBuilders[2](),
          ),
        ]
            .map((x) => Expanded(
                  flex: 1,
                  child: x,
                ))
            .toList()
            .cast<Widget>(),
      );
    }
    return Container();
  }

  // ignore: avoid_field_initializers_in_const_classes
  final _screenPadding = 110;
}
