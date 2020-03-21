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
    double maxHeight,
    this.showNavigation = true,
    this.isSingleDay = false,
  }) : super(
          date: date,
          maxHeight: maxHeight,
        );

  // ignore: public_member_api_docs
  final bool showNavigation;

  // ignore: public_member_api_docs
  final bool isSingleDay;

  @override
  _CalendarInfoCardState createState() => _CalendarInfoCardState();
}

class _CalendarInfoCardState extends InfoCardState<CalendarInfoCard> {
  InfoCardUtils utils;

  @override
  Subscription subscribeEvents(EventBus eventBus) =>
      eventBus.respond<CalendarUpdateEvent>((event) => setState(() => null));

  @override
  ListGroup build(BuildContext context) {
    final loader = CalendarWidget.of(context).feature.loader;
    final _events = (widget.isSingleDay
            ? loader.data?.getEventsForDate(widget.date)
            : loader.data?.getEventsSince(widget.date)) ??
        <CalendarEvent>[];
    final cut = InfoCardUtils.cut(
      getScreenSize(MediaQuery.of(context).size.width),
      _events.length,
    );
    return ListGroup(
      loadingKeys: const [CalendarKeys.calendar],
      showNavigation: widget.showNavigation,
      heroId: CalendarKeys.calendar,
      title: widget.isSingleDay
          ? '${CalendarLocalizations.events} - ${weekdays[widget.date.weekday - 1]}'
          : CalendarWidget.of(context).feature.name,
      counter: widget.isSingleDay ? 0 : _events.length - cut,
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
      maxHeight: widget.maxHeight,
      children: [
        if (!loader.hasLoadedData || _events.isEmpty)
          EmptyList(title: CalendarLocalizations.noEvents)
        else
          ...(_events.length > cut && !widget.isSingleDay
                  ? _events.sublist(0, cut)
                  : _events)
              .map((event) => CalendarRow(
                    event: event,
                    showAddButton: false,
                  ))
              .toList()
              .cast<Widget>(),
      ],
    );
  }
}
