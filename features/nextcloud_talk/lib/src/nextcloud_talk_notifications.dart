import 'package:flutter/material.dart';
import 'package:utils/utils.dart';

import '../nextcloud_talk.dart';
import 'nextcloud_talk_localizations.dart';
import 'nextcloud_talk_page.dart';

// ignore: public_member_api_docs
class NextcloudTalkNotificationsHandler extends NotificationsHandler {
  @override
  String getSnackBarText(Map<String, dynamic> data, BuildContext context) =>
      data['body'];

  @override
  void open(Map<String, dynamic> data, BuildContext context) {
    EventBus.of(context)
        .publish(PushMaterialPageRouteEvent(NextcloudTalkPage()));
    NextcloudTalkWidget.of(context)
        .feature
        .loader
        .client
        .notifications
        .deleteNotification(int.parse(data['group']));
  }

  @override
  AndroidNotificationChannel getAndroidNotificationHandler(
    BuildContext context,
  ) {
    final feature = NextcloudTalkWidget.of(context).feature;
    return AndroidNotificationChannel(
      feature.featureKey,
      feature.name,
      NextcloudTalkLocalizations.name,
    );
  }
}
