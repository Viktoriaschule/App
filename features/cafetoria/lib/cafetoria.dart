library cafetoria;

import 'package:cafetoria/src/cafetoria_info_card.dart';
import 'package:cafetoria/src/cafetoria_notifications.dart';
import 'package:cafetoria/src/cafetoria_page.dart';
import 'package:cafetoria/src/cafetoria_tags.dart';
import 'package:flutter/material.dart';
import 'package:utils/utils.dart';
import 'package:cafetoria/src/cafetoria_keys.dart';
import 'package:cafetoria/src/cafetoria_loader.dart';
import 'package:widgets/widgets.dart';

export 'src/cafetoria_info_card.dart';
export 'src/cafetoria_keys.dart';
export 'src/cafetoria_loader.dart';
export 'src/cafetoria_page.dart';

/// The cafetoria feature
class CafetoriaFeature implements Feature {
  @override
  final String name = 'Cafétoria';

  @override
  final String featureKey = CafetoriaKeys.cafetoria;

  @override
  final List<Feature> dependsOn = const [];

  @override
  final CafetoriaLoader loader = CafetoriaLoader();

  @override
  final CafetoriaNotificationsHandler notificationsHandler =
      CafetoriaNotificationsHandler();

  @override
  final CafetoriaTagsHandler tagsHandler = CafetoriaTagsHandler();

  @override
  InfoCard getInfoCard(DateTime date) => CafetoriaInfoCard(date: date);

  @override
  Widget getPage() => CafetoriaPage();

  @override
  CafetoriaWidget getFeatureWidget(Widget child) =>
      CafetoriaWidget(feature: this, child: child);
}

// ignore: public_member_api_docs
class CafetoriaWidget extends FeatureWidget<CafetoriaFeature> {
  // ignore: public_member_api_docs
  const CafetoriaWidget(
      {@required Widget child, @required CafetoriaFeature feature})
      : super(child: child, feature: feature);

  /// Find the closest [CafetoriaWidget] from ancestor tree.
  static CafetoriaWidget of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<CafetoriaWidget>();
}
