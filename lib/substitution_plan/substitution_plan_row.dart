import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:ginko/utils/custom_row.dart';
import 'package:ginko/utils/static.dart';
import 'package:ginko/models/models.dart';

// ignore: public_member_api_docs
class SubstitutionPlanRow extends StatelessWidget {
  // ignore: public_member_api_docs
  const SubstitutionPlanRow({
    @required this.substitution,
    this.showUnit = true,
    this.keepPadding = false,
    Key key,
  })  : assert(substitution != null, 'substitution must not be null'),
        super(key: key);

  // ignore: public_member_api_docs
  final Substitution substitution;

  // ignore: public_member_api_docs
  final bool showUnit;

  // ignore: public_member_api_docs
  final bool keepPadding;

  @override
  Widget build(BuildContext context) {
    final infoText = [];
    if ((substitution.original.subjectID != substitution.changed.subjectID &&
            substitution.changed.subjectID.isNotEmpty) ||
        substitution.type == 0) {
      infoText
          .add(Static.subjects.data.getSubject(substitution.changed.subjectID));
    }
    switch (substitution.type) {
      case 2:
        infoText.add(
            Static.subjects.data.getSubject(substitution.changed.subjectID));
        break;
      case 1:
        infoText.add('Freistunde');
        break;
      case 0:
        break;
    }
    if (substitution.info != null) {
      infoText.add(substitution.info);
    }
    return CustomRow(
      splitColor: substitution.type == 1
          ? Theme.of(context).accentColor
          : (substitution.type == 2 ? Colors.red : Colors.orange),
      leading: showUnit
          ? Align(
              alignment: Alignment(0.3, 0),
              child: Text(
                (substitution.unit + 1).toString(),
                style: TextStyle(
                  fontSize: 25,
                  color: Colors.black54,
                  fontWeight: FontWeight.w100,
                ),
              ),
            )
          : keepPadding ? Container() : null,
      title: Static.subjects.hasLoadedData ? infoText.join(' ') : null,
      subtitle: Static.subjects.hasLoadedData &&
              infoText.join(' ') !=
                  Static.subjects.data
                      .getSubject(substitution.original.subjectID)
          ? Text(
              Static.subjects.data.getSubject(substitution.original.subjectID),
              style: TextStyle(
                  decoration: TextDecoration.lineThrough,
                  color: Colors.black54,
                  fontWeight: FontWeight.w100),
            )
          : null,
      last: Row(
        children: [
          if (substitution.type != 1)
            Container(
              width: 30,
              margin: EdgeInsets.only(right: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    substitution.changed.teacherID != null
                        ? substitution.changed.teacherID.toUpperCase()
                        : '',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w100,
                    ),
                  ),
                  Text(
                    substitution.original.teacherID != null &&
                            substitution.original.teacherID !=
                                substitution.changed.teacherID
                        ? substitution.original.teacherID.toUpperCase()
                        : '',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w100,
                      color: Colors.black54,
                      decoration: TextDecoration.lineThrough,
                    ),
                  )
                ],
              ),
            ),
          if (substitution.type != 1)
            Container(
              width: 30,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    substitution.changed.roomID != null
                        ? substitution.changed.roomID.toUpperCase()
                        : '',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w100,
                    ),
                  ),
                  Text(
                    substitution.original.roomID != null &&
                            substitution.original.roomID !=
                                substitution.changed.roomID
                        ? substitution.original.roomID.toUpperCase()
                        : '',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w100,
                        color: Colors.black54,
                        decoration: TextDecoration.lineThrough),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
