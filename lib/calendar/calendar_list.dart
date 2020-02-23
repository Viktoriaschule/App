import 'package:flutter/material.dart';
import 'package:flutter_event_bus/flutter_event_bus.dart';
import 'package:viktoriaapp/calendar/calendar_page.dart';
import 'package:viktoriaapp/calendar/calendar_row.dart';
import 'package:viktoriaapp/models/keys.dart';
import 'package:viktoriaapp/utils/events.dart';
import 'package:viktoriaapp/widgets/custom_app_bar.dart';
import 'package:viktoriaapp/widgets/custom_bottom_navigation.dart';
import 'package:viktoriaapp/widgets/custom_hero.dart';
import 'package:viktoriaapp/utils/static.dart';
import 'package:viktoriaapp/utils/pages.dart';
import 'package:viktoriaapp/widgets/empty_list.dart';

// ignore: public_member_api_docs
class CalendarList extends StatefulWidget {
  @override
  CalendarListState createState() => CalendarListState();
}

// ignore: public_member_api_docs
class CalendarListState extends Interactor<CalendarList> {
  @override
  Subscription subscribeEvents(EventBus eventBus) =>
      eventBus.respond<CalendarUpdateEvent>((event) => setState(() => null));

  @override
  Widget build(BuildContext context) {
    final page = Pages.of(context).pages[Keys.calendar];
    final events = Static.calendar.data.getEventsForTimeSpan(
        DateTime.now(), DateTime.now().add(Duration(days: 6000)))
      ..sort((a, b) => a.start.compareTo(b.start));
    return Column(
      children: <Widget>[
        Expanded(
          child: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) => [
              CustomAppBar(
                title: page.title,
                actions: const [],
                sliver: true,
              ),
            ],
            body: RefreshIndicator(
              onRefresh: () => Static.calendar.loadOnline(context, force: true),
              child: events.isNotEmpty
                  ? ListView.builder(
                      padding: EdgeInsets.only(bottom: 10),
                      itemCount: events.length,
                      itemBuilder: (context, index) => Container(
                        margin: EdgeInsets.all(10),
                        child: CalendarRow(
                          event: events[index],
                        ),
                      ),
                    )
                  : EmptyList(title: 'Keine Termine'),
            ),
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
