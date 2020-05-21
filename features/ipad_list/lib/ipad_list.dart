library ipad_list;

import 'package:flutter/material.dart';
import 'package:utils/utils.dart';
import 'package:widgets/widgets.dart';

import 'src/ipad_list_events.dart';
import 'src/ipad_list_info_card.dart';
import 'src/ipad_list_keys.dart';
import 'src/ipad_list_loader.dart';
import 'src/ipad_list_localizations.dart';
import 'src/ipad_list_page.dart';

/// The iPadList feature
class IPadListFeature implements Feature {
  @override
  final String name = IPadListLocalizations.name;

  @override
  final String featureKey = IPadListKeys.iPadList;

  @override
  List<String> dependsOn(BuildContext context) => null;

  @override
  final IPadListLoader loader = IPadListLoader();

  @override
  final NotificationsHandler notificationsHandler = null;

  @override
  final TagsHandler tagsHandler = null;

  @override
  InfoCard getInfoCard(DateTime date, double maxHeight) => IPadListInfoCard(
        date: date,
        maxHeight: maxHeight,
      );

  @override
  Widget getPage() => IPadListPage(key: ValueKey(featureKey));

  @override
  IPadListWidget getFeatureWidget(Widget child) => IPadListWidget(
        feature: this,
        key: ValueKey(featureKey),
        child: child,
      );

  @override
  DateTime getHomePageDate() => null;

  @override
  Subscription subscribeToDataUpdates(
          EventBus eventBus, Function(ChangedEvent) callback) =>
      eventBus.respond<IPadListUpdateEvent>(callback);

  @override
  Duration durationToHomePageDateUpdate() => null;

  @override
  bool hasGUI = true;
}

// ignore: public_member_api_docs
class IPadListWidget extends FeatureWidget<IPadListFeature> {
  // ignore: public_member_api_docs
  const IPadListWidget(
      {@required Widget child, @required IPadListFeature feature, Key key})
      : super(child: child, feature: feature, key: key);

  /// Find the closest [IPadListWidget] from ancestor tree.
  static IPadListWidget of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<IPadListWidget>();
}
