import 'package:flutter/material.dart';
import 'package:timetable/timetable.dart';
import 'package:utils/utils.dart';
import 'package:flutter_event_bus/flutter_event_bus.dart';

/// The timetable notifications
class TimetableNotificationsHandler extends NotificationsHandler {
  @override
  String getSnackBarText(Map<String, dynamic> data, BuildContext context) =>
      'Neuer Stundenplan';

  @override
  void open(Map<String, dynamic> data, BuildContext context) =>
      EventBus.of(context).publish(PushMaterialPageRouteEvent(TimetablePage()));
}
