import 'package:flutter/material.dart';
import 'package:widgets/widgets.dart';

import 'substitution_plan_model.dart';
import 'substitution_plan_row.dart';

// ignore: public_member_api_docs
class SubstitutionList extends StatelessWidget {
  // ignore: public_member_api_docs
  const SubstitutionList({
    @required this.substitutions,
    this.showUnit = true,
    this.padding = true,
    Key key,
  }) : super(key: key);

  // ignore: public_member_api_docs
  final List<Substitution> substitutions;

  // ignore: public_member_api_docs
  final bool showUnit;

  // ignore: public_member_api_docs
  final bool padding;

  @override
  Widget build(BuildContext context) {
    int lastUnit = -1;
    return Container(
      margin: EdgeInsets.only(bottom: padding ? 6.5 : 0),
      child: Column(
        children: substitutions
            .map((s) {
              final c = SizeLimit(
                child: Container(
                  margin: EdgeInsets.only(
                    top: lastUnit == s.unit ? 1 : padding ? 9 : 0,
                    bottom: padding ? 2.5 : 0,
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
      ),
    );
  }
}
