import 'package:calendar/calendar.dart';
import 'package:calendar/src/calendar_keys.dart';
import 'package:calendar/src/calendar_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_event_bus/flutter_event_bus.dart';
import 'package:utils/utils.dart';
import 'package:widgets/widgets.dart';

import 'calendar_list.dart';
import 'calendar_model.dart';
import 'calendar_page.dart';
import 'calendar_row.dart';

// ignore: public_member_api_docs
class CalendarInfoCard extends InfoCard {
  // ignore: public_member_api_docs
  const CalendarInfoCard({
    @required DateTime date,
    this.showNavigation = true,
    this.isSingleDay = false,
  }) : super(date: date);

  // ignore: public_member_api_docs
  final bool showNavigation;

  // ignore: public_member_api_docs
  final bool isSingleDay;

  @override
  _CalendarInfoCardState createState() => _CalendarInfoCardState();
}

class _CalendarInfoCardState extends InfoCardState<CalendarInfoCard> {
  InfoCardUtils utils;

  List<CalendarEvent> getEvents(CalendarLoader loader) =>
      loader.hasLoadedData ? loader.data.getEventsSince(widget.date) : [];

  @override
  Subscription subscribeEvents(EventBus eventBus) =>
      eventBus.respond<CalendarUpdateEvent>((event) => setState(() => null));

  @override
  ListGroup getListGroup(BuildContext context, InfoCardUtils utils) {
    final loader = CalendarWidget.of(context).feature.loader;
    final _events = getEvents(loader)
        .where((event) =>
            !widget.isSingleDay ||
            event.start.isBefore(DateTime.now()) ||
            event.start == DateTime.now())
        .toList();
    return ListGroup(
      loadingKeys: const [CalendarKeys.calendar],
      showNavigation: widget.showNavigation,
      heroId: CalendarKeys.calendar,
      title: widget.isSingleDay
          ? '${CalendarLocalizations.events} - ${weekdays[widget.date.weekday - 1]}'
          : CalendarWidget.of(context).feature.name,
      counter: widget.isSingleDay ? 0 : _events.length - utils.cut,
      actions: [
        NavigationAction(
          Icons.list,
          () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (context) => Scaffold(
                  body: CalendarList(),
                ),
              ),
            );
          },
        ),
        NavigationAction(Icons.calendar_today, () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (context) => CalendarPage(),
            ),
          );
        })
      ],
      children: [
        if (!loader.hasLoadedData || _events.isEmpty)
          EmptyList(title: CalendarLocalizations.noEvents)
        else
          SizeLimit(
            child: Column(
              children: [
                ...(_events.length > utils.cut && !widget.isSingleDay
                        ? _events.sublist(0, utils.cut)
                        : _events)
                    .map((event) => Container(
                          margin: EdgeInsets.all(10),
                          child: CalendarRow(
                            event: event,
                          ),
                        ))
                    .toList()
                    .cast<Widget>(),
              ],
            ),
          ),
      ],
    );
  }
}
