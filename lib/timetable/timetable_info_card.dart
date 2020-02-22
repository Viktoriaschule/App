import 'package:flutter/material.dart';
import 'package:viktoriaapp/app/app_page.dart';
import 'package:viktoriaapp/models/models.dart';
import 'package:viktoriaapp/substitution_plan/substitution_plan_row.dart';
import 'package:viktoriaapp/timetable/timetable_row.dart';
import 'package:viktoriaapp/utils/screen_sizes.dart';
import 'package:viktoriaapp/utils/static.dart';
import 'package:viktoriaapp/widgets/custom_app_bar.dart';
import 'package:viktoriaapp/widgets/custom_bottom_navigation.dart';
import 'package:viktoriaapp/widgets/empty_list.dart';
import 'package:viktoriaapp/utils/info_card.dart';
import 'package:viktoriaapp/widgets/list_group.dart';
import 'package:viktoriaapp/widgets/size_limit.dart';

// ignore: public_member_api_docs
class TimetableInfoCard extends StatefulWidget {
  // ignore: public_member_api_docs
  const TimetableInfoCard({
    @required this.date,
    @required this.pages,
    @required this.subjects,
    @required this.changes,
    Key key,
  }) : super(key: key);

  // ignore: public_member_api_docs
  final DateTime date;

  // ignore: public_member_api_docs
  final Map<String, InlinePage> pages;

  // ignore: public_member_api_docs
  final List<TimetableSubject> subjects;

  // ignore: public_member_api_docs
  final List<Substitution> changes;

  @override
  _TimetableInfoCardState createState() => _TimetableInfoCardState();
}

class _TimetableInfoCardState extends State<TimetableInfoCard> {
  InfoCardUtils utils;

  @override
  Widget build(BuildContext context) {
    utils ??= InfoCardUtils(context, widget.date);
    return ListGroup(
      title: 'Nächste Stunden - ${weekdays[utils.weekday]}',
      counter: widget.subjects.length > utils.cut
          ? widget.subjects.length - utils.cut
          : 0,
      heroId: utils.size == ScreenSize.small
          ? Keys.timetable
          : '${Keys.timetable}-${utils.weekday}',
      heroIdNavigation: Keys.timetable,
      actions: [
        NavigationAction(
          Icons.expand_more,
          () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (context) => Scaffold(
                  appBar: CustomAppBar(
                    title: widget.pages[Keys.timetable].title,
                    actions: widget.pages[Keys.timetable].actions,
                  ),
                  body: widget.pages[Keys.timetable].content,
                ),
              ),
            );
          },
        ),
      ],
      children: [
        SizeLimit(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.subjects.isEmpty ||
                  !Static.timetable.hasLoadedData ||
                  !Static.selection.isSet())
                EmptyList(title: 'Kein Stundenplan')
              else
                ...(widget.subjects.length > utils.cut
                        ? widget.subjects.sublist(0, utils.cut)
                        : widget.subjects)
                    .map(
                  (subject) => Container(
                    margin: EdgeInsets.all(10),
                    child: Column(
                      children: [
                        TimetableRow(
                          subject: subject,
                        ),
                        ...widget.changes
                            .where((substitution) =>
                                substitution.unit == subject.unit)
                            .map((substitution) => SubstitutionPlanRow(
                                  substitution: substitution,
                                  showUnit: false,
                                  keepPadding: true,
                                ))
                            .toList()
                            .cast<Widget>(),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
