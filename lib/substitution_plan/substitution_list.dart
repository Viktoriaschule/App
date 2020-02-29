import 'package:flutter/material.dart';
import 'package:viktoriaapp/models/substitution_plan_model.dart';
import 'package:viktoriaapp/substitution_plan/substitution_plan_row.dart';
import 'package:viktoriaapp/widgets/size_limit.dart';

// ignore: public_member_api_docs
class SubstitutionList extends StatelessWidget {
  // ignore: public_member_api_docs
  const SubstitutionList({
    @required this.substitutions,
    this.showUnit = true,
    this.keepPadding = false,
    this.topPadding = true,
    Key key,
  }) : super(key: key);

  // ignore: public_member_api_docs
  final List<Substitution> substitutions;

  // ignore: public_member_api_docs
  final bool showUnit;

  // ignore: public_member_api_docs
  final bool keepPadding;

  // ignore: public_member_api_docs
  final bool topPadding;

  @override
  Widget build(BuildContext context) {
    int lastUnit = -1;
    return Column(
      children: substitutions
          .map((s) {
            final c = SizeLimit(
              child: Container(
                margin: EdgeInsets.only(
                  top: lastUnit == s.unit ? 2.5 : topPadding ? 10 : 0,
                  bottom: 2.5,
                ),
                child: SubstitutionPlanRow(
                  substitution: s,
                  showUnit: lastUnit != s.unit && showUnit,
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
