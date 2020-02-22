import 'package:flutter/material.dart';
import 'package:viktoriaapp/app/app_page.dart';
import 'package:viktoriaapp/calendar/calendar_list.dart';
import 'package:viktoriaapp/calendar/calendar_page.dart';
import 'package:viktoriaapp/calendar/calendar_row.dart';
import 'package:viktoriaapp/models/models.dart';
import 'package:viktoriaapp/utils/static.dart';
import 'package:viktoriaapp/widgets/custom_app_bar.dart';
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
    @required this.pages,
    @required this.events,
    this.showNavigation = true,
    this.isSingleDay = false,
    Key key,
  }) : super(key: key);

  // ignore: public_member_api_docs
  final DateTime date;

  // ignore: public_member_api_docs
  final Map<String, InlinePage> pages;

  // ignore: public_member_api_docs
  final List<CalendarEvent> events;

  // ignore: public_member_api_docs
  final bool showNavigation;

  // ignore: public_member_api_docs
  final bool isSingleDay;

  @override
  _CalendarInfoCardState createState() => _CalendarInfoCardState();
}

class _CalendarInfoCardState extends State<CalendarInfoCard> {
  InfoCardUtils utils;

  @override
  Widget build(BuildContext context) {
    utils ??= InfoCardUtils(context, widget.date);
    return ListGroup(
      showNavigation: widget.showNavigation,
      heroId: Keys.calendar,
      title: widget.isSingleDay
          ? 'Termine - ${weekdays[widget.date.weekday - 1]}'
          : 'Kalender',
      counter: widget.events.length - utils.cut,
      actions: [
        NavigationAction(
          Icons.list,
          () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (context) => Scaffold(
                  body: CalendarList(page: widget.pages[Keys.calendar]),
                ),
              ),
            );
          },
        ),
        NavigationAction(Icons.calendar_today, () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (context) => Scaffold(
                appBar: CustomAppBar(
                  title: widget.pages[Keys.calendar].title,
                  actions: widget.pages[Keys.calendar].actions,
                ),
                body: CalendarPage(page: widget.pages[Keys.calendar]),
              ),
            ),
          );
        })
      ],
      children: [
        if (!Static.calendar.hasLoadedData || widget.events.isEmpty)
          EmptyList(title: 'Keine Termine')
        else
          SizeLimit(
            child: Column(
              children: [
                ...(widget.events.length > utils.cut
                        ? widget.events.sublist(0, utils.cut)
                        : widget.events)
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
