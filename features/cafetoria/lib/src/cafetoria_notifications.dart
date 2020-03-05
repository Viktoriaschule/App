import 'package:cafetoria/cafetoria.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_event_bus/flutter_event_bus.dart';
import 'package:utils/utils.dart';

import 'cafetoria_page.dart';

/// The cafetoria notifications
class CafetoriaNotificationsHandler extends NotificationsHandler {
  @override
  String getSnackBarText(Map<String, dynamic> data, BuildContext context) =>
      'Neue Cafétoria-Menüs';

  @override
  void open(Map<String, dynamic> data, BuildContext context) =>
      EventBus.of(context).publish(PushMaterialPageRouteEvent(CafetoriaPage()));

  @override
  AndroidNotificationChannel getAndroidNotificationHandler(
      BuildContext context) {
    final feature = CafetoriaWidget.of(context).feature;
    return AndroidNotificationChannel(
        feature.featureKey, feature.name, 'Neue Cafétoriamenüs');
  }
}
