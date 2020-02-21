import 'package:flutter/material.dart';
import 'package:viktoriaapp/app/app_page.dart';
import 'package:viktoriaapp/calendar/calendar_page.dart';
import 'package:viktoriaapp/calendar/calendar_row.dart';
import 'package:viktoriaapp/models/keys.dart';
import 'package:viktoriaapp/utils/app_bar.dart';
import 'package:viktoriaapp/utils/bottom_navigation.dart';
import 'package:viktoriaapp/utils/custom_hero.dart';
import 'package:viktoriaapp/utils/static.dart';

// ignore: public_member_api_docs
class CalendarList extends StatelessWidget {
  // ignore: public_member_api_docs
  const CalendarList({@required this.page});

  // ignore: public_member_api_docs
  final InlinePage page;

  @override
  Widget build(BuildContext context) => Column(
        children: <Widget>[
          Expanded(
            child: CustomScrollView(
              slivers: [
                CustomAppBar(
                  title: page.title,
                  actions: page.actions,
                  sliver: true,
                ),
                SliverList(
                  delegate: SliverChildListDelegate(
                    (Static.calendar.data.getEventsForTimeSpan(DateTime.now(),
                            DateTime.now().add(Duration(days: 6000)))
                          ..sort((a, b) => a.start.compareTo(b.start)))
                        .map((event) => Container(
                              margin: EdgeInsets.all(10),
                              child: CalendarRow(
                                event: event,
                              ),
                            ))
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
          CustomHero(
            tag: Keys.navigation(Keys.calendar),
            child: Material(
              type: MaterialType.transparency,
              child: BottomNavigation(
                actions: [
                  NavigationAction(Icons.calendar_today, () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute<void>(
                        builder: (context) => Scaffold(
                          appBar: CustomAppBar(
                            title: page.title,
                            actions: page.actions,
                          ),
                          body: CalendarPage(page: page),
                        ),
                      ),
                    );
                  })
                ],
              ),
            ),
          )
        ],
      );
}
