import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:subjects/subjects.dart';
import 'package:utils/utils.dart';
import 'package:widgets/widgets.dart';

import '../substitution_plan.dart';
import 'substitution_plan_model.dart';

// ignore: public_member_api_docs
class SubstitutionPlanRow extends PreferredSize {
  // ignore: public_member_api_docs
  const SubstitutionPlanRow({
    @required this.substitution,
    this.showUnit = true,
    this.keepUnitPadding = false,
    this.keepBottomPadding = true,
  }) : assert(substitution != null, 'substitution must not be null');

  // ignore: public_member_api_docs
  final Substitution substitution;

  // ignore: public_member_api_docs
  final bool showUnit;

  // ignore: public_member_api_docs
  final bool keepBottomPadding;

  // ignore: public_member_api_docs
  final bool keepUnitPadding;

  String _getWithCase(String raw) => raw.length >= 2 &&
          grades.contains(raw.substring(0, 2)) &&
          !isSeniorGrade(raw)
      ? raw
      : raw.toUpperCase();

  @override
  Size get preferredSize => Size.fromHeight(
      customRowHeight - (showUnit ? 3 : 5) - (keepBottomPadding ? 3 : 10));

  @override
  Widget build(BuildContext context) {
    final infoText = [];
    bool lineThrough = true;
    String subtitle = SubjectsWidget.of(context).feature.loader.hasLoadedData
        ? SubjectsWidget.of(context)
            .feature
            .loader
            .data
            .getSubject(substitution.original.subjectID)
        : '';

    if ((substitution.original.subjectID != substitution.changed.subjectID ||
            (substitution.type == 0 && substitution.description.isEmpty)) &&
        substitution.changed.subjectID.isNotEmpty &&
        SubjectsWidget.of(context).feature.loader.hasLoadedData) {
      infoText.add(SubjectsWidget.of(context)
          .feature
          .loader
          .data
          .getSubject(substitution.changed.subjectID));
    }

    switch (substitution.type) {
      case 2:
        if (SubjectsWidget.of(context).feature.loader.hasLoadedData) {
          infoText.add(SubjectsWidget.of(context)
              .feature
              .loader
              .data
              .getSubject(substitution.changed.subjectID));
          subtitle = Static.user.isTeacher()
              ? SubstitutionPlanLocalizations.examSupervision
              : SubstitutionPlanLocalizations.exam;
          lineThrough = false;
        }
        break;
      case 1:
        infoText.add(SubstitutionPlanLocalizations.freeLesson);
        break;
      case 0:
        break;
    }
    if (substitution.info != null && substitution.info.isNotEmpty) {
      infoText.add(substitution.info);
    }
    if (substitution.description != null &&
        substitution.description.isNotEmpty) {
      if (substitution.original.subjectID == substitution.changed.subjectID ||
          substitution.changed.subjectID.isEmpty) {
        subtitle = substitution.description;
        lineThrough = false;
      }
    }
    return Container(
      margin: EdgeInsets.only(
        left: 10,
        right: 10,
        top: showUnit ? 7 : 5,
        bottom: keepBottomPadding ? 7 : 0,
      ),
      child: CustomRow(
        heroTag: substitution,
        hasMargin: false,
        splitColor: substitution.type == 1
            ? Theme.of(context).accentColor
            : (substitution.type == 2 ? Colors.red : Colors.orange),
        leading: showUnit
            ? Text(
                (substitution.unit + 1).toString(),
                style: TextStyle(
                  fontSize: 25,
                  color: ThemeWidget.of(context).textColorLight,
                  fontWeight: FontWeight.w100,
                ),
              )
            : keepUnitPadding ? Container() : null,
        title: Text(
          SubjectsWidget.of(context).feature.loader.hasLoadedData
              ? (infoText.isNotEmpty
                  ? infoText.join(' ')
                  : SubjectsWidget.of(context)
                      .feature
                      .loader
                      .data
                      .getSubject(substitution.original.subjectID))
              : '',
          style: TextStyle(
            fontSize: 17,
            color: Theme.of(context).accentColor,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            decoration: lineThrough ? TextDecoration.lineThrough : null,
            color: ThemeWidget.of(context).textColorLight,
            fontWeight: FontWeight.w100,
          ),
        ),
        last: Row(
          children: [
            Container(
              width: 35,
              margin: EdgeInsets.only(right: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    substitution.changed.participantID != null
                        ? _getWithCase(substitution.changed.participantID)
                        : substitution.original.participantID != null
                            ? _getWithCase(substitution.original.participantID)
                            : '',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w300,
                      color: ThemeWidget.of(context).textColor,
                      fontFamily: 'RobotoMono',
                    ),
                  ),
                  Text(
                    substitution.original.participantID != null &&
                            substitution.changed.participantID != null &&
                            substitution.original.participantID !=
                                substitution.changed.participantID
                        ? substitution.original.participantID.toUpperCase()
                        : '',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w300,
                      color: ThemeWidget.of(context).textColor,
                      decoration: TextDecoration.lineThrough,
                      fontFamily: 'RobotoMono',
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 30,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    substitution.changed.roomID != null
                        ? substitution.changed.roomID.toUpperCase()
                        : substitution.original.roomID != null
                            ? substitution.original.roomID.toUpperCase()
                            : '',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w300,
                      color: ThemeWidget.of(context).textColor,
                      fontFamily: 'RobotoMono',
                    ),
                  ),
                  Text(
                    substitution.type != 1 &&
                            substitution.original.roomID != null &&
                            substitution.changed.roomID != null &&
                            substitution.original.roomID !=
                                substitution.changed.roomID
                        ? substitution.original.roomID.toUpperCase()
                        : '',
                    style: TextStyle(
                      fontSize: 14,
                      color: ThemeWidget.of(context).textColor,
                      decoration: TextDecoration.lineThrough,
                      fontWeight: FontWeight.w300,
                      fontFamily: 'RobotoMono',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
