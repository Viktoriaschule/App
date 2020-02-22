import 'package:flutter/material.dart';
import 'package:viktoriaapp/calendar/calendar_page.dart';
import 'package:viktoriaapp/calendar/calendar_row.dart';
import 'package:viktoriaapp/models/keys.dart';
import 'package:viktoriaapp/widgets/custom_app_bar.dart';
import 'package:viktoriaapp/widgets/custom_bottom_navigation.dart';
import 'package:viktoriaapp/widgets/custom_hero.dart';
import 'package:viktoriaapp/utils/static.dart';
import 'package:viktoriaapp/utils/pages.dart';

// ignore: public_member_api_docs
class CalendarList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final page = Pages.of(context).pages[Keys.calendar];
    return Column(
      children: <Widget>[
        Expanded(
          child: CustomScrollView(
            slivers: [
              CustomAppBar(
                title: page.title,
                actions: const [],
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
            child: CustomBottomNavigation(
              actions: [
                NavigationAction(Icons.calendar_today, () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute<void>(
                      builder: (context) => CalendarPage(),
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
}
