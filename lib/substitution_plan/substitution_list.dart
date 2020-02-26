import 'package:flutter/material.dart';
import 'package:viktoriaapp/models/substitution_plan_model.dart';
import 'package:viktoriaapp/substitution_plan/substitution_plan_row.dart';
import 'package:viktoriaapp/widgets/size_limit.dart';

// ignore: public_member_api_docs
class SubstitutionList extends StatelessWidget {
  // ignore: public_member_api_docs
  const SubstitutionList({
    @required this.substitutions,
    Key key,
  }) : super(key: key);

  // ignore: public_member_api_docs
  final List<Substitution> substitutions;

  @override
  Widget build(BuildContext context) {
    int lastUnit = -1;
    return Column(
      children: substitutions
          .map((s) {
            final c = SizeLimit(
              child: Container(
                margin: EdgeInsets.only(
                  top: lastUnit == s.unit ? 2.5 : 10,
                  bottom: 2.5,
                  left: 10,
                  right: 10,
                ),
                child: SubstitutionPlanRow(
                  substitution: s,
                  showUnit: lastUnit != s.unit,
                  keepPadding: true,
                ),
              ),
            );
            lastUnit = s.unit;
            return c;
          })
          .toList()
          .cast<Widget>(),
    );
  }
}
