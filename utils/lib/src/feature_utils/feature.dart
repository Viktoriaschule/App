import 'package:flutter/material.dart';
import 'package:utils/src/feature_utils/feature_widget.dart';
import 'package:utils/src/feature_utils/notifications.dart';
import 'package:utils/src/feature_utils/tags.dart';
import 'package:utils/src/loader.dart';

export 'feature_widget.dart';
export 'keys.dart';
export 'notifications.dart';
export 'tags.dart';

/// All features have to be subclasses of a feature
abstract class Feature {
  // ignore: public_member_api_docs
  const Feature({
    @required this.loader,
    @required this.featureKey,
    @required this.name,
    @required this.notificationsHandler,
    @required this.tagsHandler,
    this.dependsOn = const [],
  });

  /// The key that should be used for this feature
  final String featureKey;

  /// The name that should be used for this feature
  ///
  /// This will be the user readable title in the app bar and in any places in the app
  final String name;

  /// A list of all features that must be included and loaded first to use this feature
  final List<Feature> dependsOn;

  /// The loader with all data for this feature
  final Loader loader;

  /// All notifications for this feature
  ///
  /// If a feature does not want do receive notifications, the notifications handler should be null
  final NotificationsHandler notificationsHandler;

  /// The tags handling for this feature
  ///
  /// If the feature does not handle any tags, the handler should be null
  final TagsHandler tagsHandler;

  //TODO: Replace with InfoCard type
  /// The information card of this feature for the home page of the app
  Widget getInfoCard(DateTime date);

  /// The custom page for this feature
  Widget getPage();

  /// The inherited feature widget
  FeatureWidget getFeatureWidget(Widget child);
}
