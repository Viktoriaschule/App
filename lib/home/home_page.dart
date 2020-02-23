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

    final timetableView = TimetableInfoCard(date: day);
    final substitutionPlanView = SubstitutionPlanInfoCard(date: day);
    final aiXformationView = AiXformationInfoCard(date: day);
    final cafetoriaView = CafetoriaInfoCard(date: day);
    final calendarView = CalendarInfoCard(date: day);

    if (size == ScreenSize.small) {
      return Container(
        color: Theme.of(context).backgroundColor,
        child: Column(
          children: [
            timetableView,
            substitutionPlanView,
            calendarView,
            cafetoriaView,
            aiXformationView,
          ],
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
              substitutionPlanView,
              timetableView,
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
              calendarView,
              cafetoriaView,
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
              aiXformationView,
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
              substitutionPlanView,
              cafetoriaView,
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
              timetableView,
              calendarView,
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
            child: aiXformationView,
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
