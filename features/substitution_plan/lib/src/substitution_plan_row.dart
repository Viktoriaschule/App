import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
      customRowHeight - (showUnit ? 0 : 5) - (keepBottomPadding ? 0 : 10));

  @override
  Widget build(BuildContext context) {
    final infoText = [];
    bool lineThrough = true;
    String subtitle =
        Static.subjects.data.getSubject(substitution.original.subjectID);

    if ((substitution.original.subjectID != substitution.changed.subjectID ||
            (substitution.type == 0 && substitution.description.isEmpty)) &&
        substitution.changed.subjectID.isNotEmpty) {
      infoText
          .add(Static.subjects.data.getSubject(substitution.changed.subjectID));
    }

    switch (substitution.type) {
      case 2:
        infoText.add(
            Static.subjects.data.getSubject(substitution.changed.subjectID));
        subtitle = Static.user.isTeacher()
            ? SubstitutionPlanLocalizations.examSupervision
            : SubstitutionPlanLocalizations.exam;
        lineThrough = false;
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
        top: showUnit ? 10 : 5,
        bottom: keepBottomPadding ? 10 : 0,
      ),
      child: CustomRow(
        heroTag: substitution,
        hasMargin: false,
        splitColor: substitution.type == 1
            ? Theme
            .of(context)
            .accentColor
            : (substitution.type == 2 ? Colors.red : Colors.orange),
        leading: showUnit
            ? Text(
          (substitution.unit + 1).toString(),
          style: TextStyle(
            fontSize: 25,
            color: ThemeWidget
                .of(context)
                .textColorLight,
            fontWeight: FontWeight.w100,
          ),
        )
            : keepUnitPadding ? Container() : null,
        title: Static.subjects.hasLoadedData
            ? (infoText.isNotEmpty
            ? infoText.join(' ')
            : Static.subjects.data
            .getSubject(substitution.original.subjectID))
            : null,
        subtitle: Text(
          subtitle,
          style: TextStyle(
            decoration: lineThrough ? TextDecoration.lineThrough : null,
            color: ThemeWidget
                .of(context)
                .textColorLight,
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
                      color: ThemeWidget
                          .of(context)
                          .textColor,
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
                      color: ThemeWidget
                          .of(context)
                          .textColor,
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
                      color: ThemeWidget
                          .of(context)
                          .textColor,
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
                      color: ThemeWidget
                          .of(context)
                          .textColor,
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
