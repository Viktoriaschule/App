import 'package:cafetoria/cafetoria.dart';
import 'package:flutter/material.dart';
import 'package:flutter_event_bus/flutter_event_bus.dart';
import 'package:utils/utils.dart';

/// The cafetoria notifications
class CafetoriaNotificationsHandler extends NotificationsHandler {
  @override
  String getSnackBarText(Map<String, dynamic> data, BuildContext context) =>
      CafetoriaLocalizations.newMenus;

  @override
  void open(Map<String, dynamic> data, BuildContext context) =>
      EventBus.of(context).publish(PushMaterialPageRouteEvent(CafetoriaPage()));

  @override
  AndroidNotificationChannel getAndroidNotificationHandler(
      BuildContext context) {
    final feature = CafetoriaWidget.of(context).feature;
    return AndroidNotificationChannel(
        feature.featureKey, feature.name, CafetoriaLocalizations.newMenus);
  }
}
