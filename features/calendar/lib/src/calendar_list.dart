import 'package:calendar/calendar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_event_bus/flutter_event_bus.dart';
import 'package:widgets/widgets.dart';

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
    final loader = CalendarWidget.of(context).feature.loader;
    final events =
        loader.hasLoadedData ? loader.data.getEventsSince(DateTime.now()) : [];
    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) => [
        CustomAppBar(
          title: CalendarLocalizations.name,
          actions: [
            IconButton(
              icon: Icon(Icons.calendar_today),
              onPressed: () => Navigator.of(context).pushReplacement(
                MaterialPageRoute<void>(
                  builder: (context) => CalendarPage(),
                ),
              ),
            )
          ],
          sliver: true,
          loadingKeys: const [CalendarKeys.calendar],
        ),
      ],
      body: CustomRefreshIndicator(
        loadOnline: () => loader.loadOnline(context, force: true),
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
            : EmptyList(title: CalendarLocalizations.noEvents),
      ),
    );
  }
}
