import 'package:flutter/material.dart';
import 'package:ginko/app/app_page.dart';
import 'package:ginko/calendar/calendar_page.dart';
import 'package:ginko/calendar/calendar_row.dart';
import 'package:ginko/models/keys.dart';
import 'package:ginko/plugins/platform/platform.dart';
import 'package:ginko/utils/app_bar.dart';
import 'package:ginko/utils/bottom_navigation.dart';
import 'package:ginko/utils/static.dart';

// ignore: public_member_api_docs
class CalendarList extends StatelessWidget {
  // ignore: public_member_api_docs
  const CalendarList({@required this.page});

  // ignore: public_member_api_docs
  final InlinePage page;

  @override
  Widget build(BuildContext context) => Stack(
        children: <Widget>[
          Positioned.fill(
            child: Hero(
              tag: !Platform().isWeb ? Keys.calendar : key,
              child: Container(color: Theme.of(context).primaryColor),
            ),
          ),
          Column(
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
                        (Static.calendar.data.getEventsForTimeSpan(
                                DateTime.now(),
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
              Hero(
                tag: !Platform().isWeb ? Keys.navigation(Keys.calendar) : this,
                child: Material(
                  type: MaterialType.transparency,
                  child: BottomNavigation(
                    actions: [
                      NavigationAction(Icons.expand_less, () {
                        Navigator.pop(context);
                      }),
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
          ),
        ],
      );
}
