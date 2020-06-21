library cafetoria;

import 'package:flutter/material.dart';
import 'package:utils/utils.dart';
import 'package:widgets/widgets.dart';

import 'src/cafetoria_events.dart';
import 'src/cafetoria_info_card.dart';
import 'src/cafetoria_keys.dart';
import 'src/cafetoria_loader.dart';
import 'src/cafetoria_localizations.dart';
import 'src/cafetoria_notifications.dart';
import 'src/cafetoria_page.dart';
import 'src/cafetoria_tags.dart';

export 'src/cafetoria_events.dart';
export 'src/cafetoria_info_card.dart';
export 'src/cafetoria_keys.dart';
export 'src/cafetoria_loader.dart';
export 'src/cafetoria_localizations.dart';
export 'src/cafetoria_login_dialog.dart';
export 'src/cafetoria_model.dart';
export 'src/cafetoria_page.dart';
export 'src/cafetoria_row.dart';

/// The cafetoria feature
class CafetoriaFeature implements Feature {
  @override
  final String name = CafetoriaLocalizations.name;

  @override
  final String featureKey = CafetoriaKeys.cafetoria;

  @override
  List<String> dependsOn(BuildContext context) => null;

  @override
  final CafetoriaLoader loader = CafetoriaLoader();

  @override
  final CafetoriaNotificationsHandler notificationsHandler =
      CafetoriaNotificationsHandler();

  @override
  final CafetoriaTagsHandler tagsHandler = CafetoriaTagsHandler();

  @override
  List<Option> extraSettings;

  @override
  InfoCard getInfoCard(DateTime date, double maxHeight) => CafetoriaInfoCard(
        date: date,
        maxHeight: maxHeight,
      );

  @override
  Widget getPage() => CafetoriaPage(key: ValueKey(featureKey));

  @override
  CafetoriaWidget getFeatureWidget(Widget child) => CafetoriaWidget(
        feature: this,
        key: ValueKey(featureKey),
        child: child,
      );

  @override
  DateTime getHomePageDate() {
    if (loader.hasLoadedData) {
      final now = DateTime(
          DateTime.now().year, DateTime.now().month, DateTime.now().day);
      final days =
          loader.data.days.where((day) => day.date.isAfter(now)).toList();
      return days.isNotEmpty ? days.first.date : null;
    }
    return null;
  }

  @override
  Subscription subscribeToDataUpdates(
          EventBus eventBus, Function(ChangedEvent) callback) =>
      eventBus.respond<CafetoriaUpdateEvent>(callback);

  @override
  Duration durationToHomePageDateUpdate() =>
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day)
          .add(Duration(days: 1))
          .difference(DateTime.now());

  @override
  bool hasGUI = true;
}

// ignore: public_member_api_docs
class CafetoriaWidget extends FeatureWidget<CafetoriaFeature> {
  // ignore: public_member_api_docs
  const CafetoriaWidget(
      {@required Widget child, @required CafetoriaFeature feature, Key key})
      : super(child: child, feature: feature, key: key);

  /// Find the closest [CafetoriaWidget] from ancestor tree.
  static CafetoriaWidget of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<CafetoriaWidget>();
}
