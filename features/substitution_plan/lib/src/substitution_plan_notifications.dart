import 'package:flutter/cupertino.dart';
import 'package:substitution_plan/substitution_plan.dart';
import 'package:utils/utils.dart';
import 'package:flutter_event_bus/flutter_event_bus.dart';

/// The substitution plan notifications
class SubstitutionPlanNotificationsHandler extends NotificationsHandler {
  @override
  String getSnackBarText(Map<String, dynamic> data, BuildContext context) {
    final loader = SubstitutionPlanWidget.of(context)?.feature?.loader;
    return 'Neuer Vertretungsplan${loader?.hasLoadedData ?? false ? ' für ${weekdays[loader.data.days[int.parse(data['day'])].date.weekday - 1]}' : ''}';
  }

  @override
  void open(Map<String, dynamic> data, BuildContext context) =>
      EventBus.of(context)
          .publish(PushMaterialPageRouteEvent(SubstitutionPlanPage(
        day: int.parse(data['day']),
      )));
}
