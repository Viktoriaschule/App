import 'package:aixformation/aixformation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_event_bus/flutter_event_bus.dart';
import 'package:utils/utils.dart';

import 'aixformation_model.dart';
import 'aixformation_post.dart';

/// The aixformation notifications
class AiXformationNotificationsHandler extends NotificationsHandler {
  @override
  String getSnackBarText(Map<String, dynamic> data, BuildContext context) =>
      'Neuer AiXformation-Artikel';

  @override
  void open(Map<String, dynamic> data, BuildContext context) =>
      EventBus.of(context).publish(PushMaterialPageRouteEvent(AiXformationPost(
        // ignore: missing_required_param
        post: Post(url: data['url']),
        posts: AiXFormationWidget.of(context).feature.loader.hasLoadedData
            ? AiXFormationWidget.of(context).feature.loader.data.posts
            : [],
      )));

  @override
  AndroidNotificationChannel getAndroidNotificationHandler(
      BuildContext context) {
    final feature = AiXFormationWidget.of(context).feature;
    return AndroidNotificationChannel(
        feature.featureKey, feature.name, 'Neue AiXformationartikel');
  }
}
