library aixformation;

import 'package:flutter/material.dart';
import 'package:utils/utils.dart';
import 'package:widgets/widgets.dart';

import 'src/aixformation_events.dart';
import 'src/aixformation_info_card.dart';
import 'src/aixformation_keys.dart';
import 'src/aixformation_loader.dart';
import 'src/aixformation_localizations.dart';
import 'src/aixformation_notifications.dart';
import 'src/aixformation_page.dart';

export 'src/aixformation_events.dart';
export 'src/aixformation_info_card.dart';
export 'src/aixformation_keys.dart';
export 'src/aixformation_loader.dart';
export 'src/aixformation_localizations.dart';
export 'src/aixformation_model.dart';
export 'src/aixformation_page.dart';
export 'src/aixformation_post.dart';
export 'src/aixformation_row.dart';

/// The aixformation feature
class AiXformationFeature implements Feature {
  @override
  final String name = AiXformationLocalizations.name;

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
  TagsHandler tagsHandler;

  @override
  List<Option> extraSettings;

  @override
  InfoCard getInfoCard(DateTime date, double maxHeight) => AiXformationInfoCard(
        date: date,
        maxHeight: maxHeight,
      );

  @override
  Widget getPage() => AiXformationPage(key: ValueKey(featureKey));

  @override
  AiXformationWidget getFeatureWidget(Widget child) => AiXformationWidget(
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
  Subscription subscribeToDataUpdates(
          EventBus eventBus, Function(ChangedEvent) callback) =>
      eventBus.respond<AiXformationUpdateEvent>(callback);

  @override
  Duration durationToHomePageDateUpdate() => null;

  @override
  bool hasGUI = true;
}

// ignore: public_member_api_docs
class AiXformationWidget extends FeatureWidget<AiXformationFeature> {
  // ignore: public_member_api_docs
  const AiXformationWidget(
      {@required Widget child, @required AiXformationFeature feature, Key key})
      : super(child: child, feature: feature, key: key);

  /// Find the closest [AiXformationWidget] from ancestor tree.
  static AiXformationWidget of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AiXformationWidget>();
}
