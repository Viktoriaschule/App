import 'package:flutter/material.dart';
import 'package:flutter_event_bus/flutter_event_bus.dart';
import 'package:utils/src/feature_utils/feature_widget.dart';
import 'package:utils/src/feature_utils/notifications.dart';
import 'package:utils/src/feature_utils/tags.dart';
import 'package:utils/src/loading/loader.dart';
import 'package:utils/utils.dart';
import 'package:widgets/widgets.dart';

export 'package:flutter_event_bus/flutter_event_bus.dart';

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
    @required this.hasGUI,
  });

  /// The key that should be used for this feature
  final String featureKey;

  /// The name that should be used for this feature
  ///
  /// This will be the user readable title in the app bar and in any places in the app
  final String name;

  /// If the feature has a GUI this should be set
  ///
  /// If no GUI is present the info card and page are never requested
  final bool hasGUI;

  /// A list of all features that must be included and loaded first to use this feature
  List<String> dependsOn(BuildContext context);

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

  /// If the feature wants to control the date for the home page,
  /// it have to return a date, otherwise, return null
  DateTime getHomePageDate();

  /// Subscribes to all data updates of this feature
  Subscription subscribeToDataUpdates(
      EventBus eventBus, Function(ChangedEvent) callback);

  /// Returns the duration between the current moment and the next `getHomePageDate()` update
  Duration durationToHomePageDateUpdate();

  /// The information card of this feature for the home page of the app
  InfoCard getInfoCard(DateTime date, double maxHeight);

  /// The custom page for this feature
  Widget getPage();

  /// The inherited feature widget
  FeatureWidget getFeatureWidget(Widget child);
}
