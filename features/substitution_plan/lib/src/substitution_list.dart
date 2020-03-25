import 'package:flutter/material.dart';

import 'substitution_plan_model.dart';
import 'substitution_plan_row.dart';

/// Get a list of substitutions with correct unit numbering
List<PreferredSize> getSubstitutionList(
  List<Substitution> substitutions, {
  bool showUnit = true,
  bool keepUnitPadding = true,
}) {
  int lastUnit = -1;
  int nextIndex = 1;
  return substitutions
      .map((s) {
        final nextSubstitution =
            nextIndex < substitutions.length ? substitutions[nextIndex] : null;
        final c = SubstitutionPlanRow(
          substitution: s,
          showUnit: lastUnit != s.unit && showUnit,
          keepUnitPadding: keepUnitPadding,
          keepBottomPadding:
              nextSubstitution != null && nextSubstitution.unit != s.unit,
        );
        nextIndex++;
        lastUnit = s.unit;
        return c;
      })
      .toList()
      .cast<PreferredSize>();
}
