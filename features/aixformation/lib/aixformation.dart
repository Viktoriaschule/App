library aixformation;

import 'package:aixformation/src/aixformation_info_card.dart';
import 'package:aixformation/src/aixformation_keys.dart';
import 'package:aixformation/src/aixformation_loader.dart';
import 'package:aixformation/src/aixformation_notifications.dart';
import 'package:aixformation/src/aixformation_page.dart';
import 'package:flutter/material.dart';
import 'package:utils/utils.dart';
import 'package:widgets/widgets.dart';

export 'src/aixformation_events.dart';
export 'src/aixformation_info_card.dart';
export 'src/aixformation_loader.dart';
export 'src/aixformation_model.dart';
export 'src/aixformation_page.dart';
export 'src/aixformation_post.dart';

/// The aixformation feature
class AiXformationFeature implements Feature {
  @override
  final String name = 'Aixformation';

  @override
  final String featureKey = AiXformationKeys.aixformation;

  @override
  List<String> dependsOn(BuildContext context) => null;

  @override
  final AiXformationLoader loader = AiXformationLoader();

  @override
  final AiXformationNotificationsHandler notificationsHandler =
      AiXformationNotificationsHandler();

  @override
  final TagsHandler tagsHandler = null;

  @override
  InfoCard getInfoCard(DateTime date) => AiXformationInfoCard(date: date);

  @override
  Widget getPage() => AiXformationPage(key: ValueKey(featureKey));

  @override
  AiXFormationWidget getFeatureWidget(Widget child) => AiXFormationWidget(
        feature: this,
        key: ValueKey(featureKey),
        child: child,
      );

  @override
  DateTime getHomePageDate() =>
      loader.hasLoadedData && loader.data.posts.isNotEmpty
          ? loader.data.posts.first.date
          : null;

  @override
  Duration durationToHomePageDateUpdate() => null;
}

// ignore: public_member_api_docs
class AiXFormationWidget extends FeatureWidget<AiXformationFeature> {
  // ignore: public_member_api_docs
  const AiXFormationWidget(
      {@required Widget child, @required AiXformationFeature feature, Key key})
      : super(child: child, feature: feature, key: key);

  /// Find the closest [AiXFormationWidget] from ancestor tree.
  static AiXFormationWidget of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AiXFormationWidget>();
}
