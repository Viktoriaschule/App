library reservations;

import 'package:flutter/material.dart';
import 'package:utils/utils.dart';
import 'package:widgets/widgets.dart';

import 'src/reservations_events.dart';
import 'src/reservations_info_card.dart';
import 'src/reservations_keys.dart';
import 'src/reservations_loader.dart';
import 'src/reservations_localizations.dart';
import 'src/reservations_page.dart';

/// The reservations feature
class ReservationsFeature implements Feature {
  @override
  final String name = ReservationsLocalizations.name;

  @override
  final String featureKey = ReservationsKeys.reservations;

  @override
  List<String> dependsOn(BuildContext context) => ['timetable'];

  @override
  final ReservationsLoader loader = ReservationsLoader();

  @override
  final NotificationsHandler notificationsHandler = null;

  @override
  final TagsHandler tagsHandler = null;

  @override
  InfoCard getInfoCard(DateTime date, double maxHeight) => ReservationsInfoCard(
        date: date,
        maxHeight: maxHeight,
      );

  @override
  Widget getPage() => ReservationsPage(key: ValueKey(featureKey));

  @override
  ReservationsWidget getFeatureWidget(Widget child) => ReservationsWidget(
        feature: this,
        key: ValueKey(featureKey),
        child: child,
      );

  @override
  DateTime getHomePageDate() => null;

  @override
  Subscription subscribeToDataUpdates(
          EventBus eventBus, Function(ChangedEvent) callback) =>
      eventBus.respond<ReservationsUpdateEvent>(callback);

  @override
  Duration durationToHomePageDateUpdate() => null;
}

// ignore: public_member_api_docs
class ReservationsWidget extends FeatureWidget<ReservationsFeature> {
  // ignore: public_member_api_docs
  const ReservationsWidget(
      {@required Widget child, @required ReservationsFeature feature, Key key})
      : super(child: child, feature: feature, key: key);

  /// Find the closest [ReservationsWidget] from ancestor tree.
  static ReservationsWidget of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<ReservationsWidget>();
}
