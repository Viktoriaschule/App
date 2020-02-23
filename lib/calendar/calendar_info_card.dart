import 'package:flutter/material.dart';
import 'package:flutter_event_bus/flutter_event_bus.dart';
import 'package:viktoriaapp/calendar/calendar_list.dart';
import 'package:viktoriaapp/calendar/calendar_page.dart';
import 'package:viktoriaapp/calendar/calendar_row.dart';
import 'package:viktoriaapp/models/models.dart';
import 'package:viktoriaapp/utils/events.dart';
import 'package:viktoriaapp/utils/static.dart';
import 'package:viktoriaapp/widgets/custom_bottom_navigation.dart';
import 'package:viktoriaapp/widgets/empty_list.dart';
import 'package:viktoriaapp/utils/info_card.dart';
import 'package:viktoriaapp/widgets/list_group.dart';
import 'package:viktoriaapp/widgets/size_limit.dart';

// ignore: public_member_api_docs
class CalendarInfoCard extends StatefulWidget {
  // ignore: public_member_api_docs
  const CalendarInfoCard({
    @required this.date,
    this.showNavigation = true,
    this.isSingleDay = false,
    Key key,
  }) : super(key: key);

  // ignore: public_member_api_docs
  final DateTime date;

  // ignore: public_member_api_docs
  final bool showNavigation;

  // ignore: public_member_api_docs
  final bool isSingleDay;

  @override
  _CalendarInfoCardState createState() => _CalendarInfoCardState();
}

class _CalendarInfoCardState extends Interactor<CalendarInfoCard> {
  InfoCardUtils utils;

  List<CalendarEvent> _events;

  List<CalendarEvent> getEvents() => Static.calendar.hasLoadedData
      ? (Static.calendar.data.getEventsForTimeSpan(
              widget.date,
              widget.isSingleDay
                  ? widget.date
                  : widget.date.add(Duration(days: 730)))
            ..sort((a, b) => a.start.compareTo(b.start)))
          .toList()
      : [];

  @override
  void initState() {
    _events = getEvents();
    super.initState();
  }

  @override
  Subscription subscribeEvents(EventBus eventBus) =>
      eventBus.respond<CalendarUpdateEvent>(
          (event) => setState(() => _events = getEvents()));

  @override
  Widget build(BuildContext context) {
    utils ??= InfoCardUtils(context, widget.date);
    return ListGroup(
      pageKey: Keys.calendar,
      showNavigation: widget.showNavigation,
      heroId: Keys.calendar,
      title: widget.isSingleDay
          ? 'Termine - ${weekdays[widget.date.weekday - 1]}'
          : 'Kalender',
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
        if (!Static.calendar.hasLoadedData || _events.isEmpty)
          EmptyList(title: 'Keine Termine')
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
