library nextcloud_talk;

import 'package:flutter/material.dart';
import 'package:nextcloud_talk/src/nextcloud_talk_events.dart';
import 'package:nextcloud_talk/src/nextcloud_talk_keys.dart';
import 'package:nextcloud_talk/src/nextcloud_talk_loader.dart';
import 'package:utils/utils.dart';
import 'package:widgets/widgets.dart';

import 'src/nextcloud_talk_info_card.dart';
import 'src/nextcloud_talk_localizations.dart';
import 'src/nextcloud_talk_page.dart';

/// The Nextcloud Talk feature
class NextcloudTalkFeature implements Feature {
  @override
  String get name => NextcloudTalkLocalizations.name;

  @override
  String get featureKey => NextcloudTalkKeys.nextcloudTalk;

  @override
  List<String> dependsOn(BuildContext context) => null;

  @override
  NextcloudTalkLoader loader = NextcloudTalkLoader();

  @override
  NotificationsHandler get notificationsHandler => null;

  @override
  TagsHandler get tagsHandler => null;

  @override
  InfoCard getInfoCard(DateTime date, double maxHeight) =>
      NextcloudTalkInfoCard(
        date: date,
        maxHeight: maxHeight,
      );

  @override
  Widget getPage() => NextcloudTalkPage(key: ValueKey(featureKey));

  @override
  NextcloudTalkWidget getFeatureWidget(Widget child) => NextcloudTalkWidget(
        feature: this,
        key: ValueKey(featureKey),
        child: child,
      );

  @override
  DateTime getHomePageDate() => null;

  @override
  Duration durationToHomePageDateUpdate() => null;

  @override
  Subscription subscribeToDataUpdates(
          EventBus eventBus, Function(ChangedEvent p1) callback) =>
      eventBus.respond<NextcloudTalkUpdateEvent>(callback);
}

// ignore: public_member_api_docs
class NextcloudTalkWidget extends FeatureWidget<NextcloudTalkFeature> {
  // ignore: public_member_api_docs
  const NextcloudTalkWidget({
    @required Widget child,
    @required NextcloudTalkFeature feature,
    Key key,
  }) : super(
          child: child,
          feature: feature,
          key: key,
        );

  /// Find the closest [NextcloudTalkWidget] from ancestor tree.
  static NextcloudTalkWidget of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<NextcloudTalkWidget>();
}
