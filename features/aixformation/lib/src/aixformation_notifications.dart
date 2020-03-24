import 'package:aixformation/aixformation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_event_bus/flutter_event_bus.dart';
import 'package:utils/utils.dart';

/// The aixformation notifications
class AiXformationNotificationsHandler extends NotificationsHandler {
  @override
  String getSnackBarText(Map<String, dynamic> data, BuildContext context) =>
      AiXformationLocalizations.newAiXformationArticle;

  @override
  void open(Map<String, dynamic> data, BuildContext context) =>
      EventBus.of(context).publish(PushMaterialPageRouteEvent(AiXformationPost(
        // ignore: missing_required_param
        post: Post(url: data['url']),
        posts: AiXformationWidget.of(context).feature.loader.hasLoadedData
            ? AiXformationWidget.of(context).feature.loader.data.posts
            : [],
      )));

  @override
  AndroidNotificationChannel getAndroidNotificationHandler(
      BuildContext context) {
    final feature = AiXformationWidget
        .of(context)
        .feature;
    return AndroidNotificationChannel(feature.featureKey, feature.name,
        AiXformationLocalizations.newAiXformationArticles);
  }
}
