import 'package:flutter/material.dart';

import 'substitution_plan_model.dart';
import 'substitution_plan_row.dart';

/// Get a list of substitutions with correct unit numbering
List<Widget> getSubstitutionList(
  List<Substitution> substitutions, {
  bool showUnit = true,
  bool keepUnitPadding = true,
}) {
  int lastUnit = -1;
  return substitutions
      .map((s) {
        final c = SubstitutionPlanRow(
          substitution: s,
          showUnit: lastUnit != s.unit && showUnit,
          keepUnitPadding: keepUnitPadding,
        );
        lastUnit = s.unit;
        return c;
      })
      .toList()
      .cast<Widget>();
}
