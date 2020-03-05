import 'package:flutter/cupertino.dart';
import 'package:utils/utils.dart';
import 'package:flutter_event_bus/flutter_event_bus.dart';
import 'cafetoria_page.dart';

/// The cafetoria notifications
class CafetoriaNotificationsHandler extends NotificationsHandler {
  @override
  String getSnackBarText(Map<String, dynamic> data, BuildContext context) =>
      'Neue Cafétoria-Menüs';

  @override
  void open(Map<String, dynamic> data, BuildContext context) =>
      EventBus.of(context).publish(PushMaterialPageRouteEvent(CafetoriaPage()));
}
