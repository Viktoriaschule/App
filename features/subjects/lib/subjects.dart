library subjects;

import 'package:flutter/material.dart';
import 'package:utils/utils.dart';
import 'package:widgets/widgets.dart';

import 'src/subjects_events.dart';
import 'src/subjects_keys.dart';
import 'src/subjects_loader.dart';

export 'src/subjects_keys.dart';
export 'src/subjects_loader.dart';
export 'src/subjects_model.dart';

/// The subjects feature
class SubjectsFeature implements Feature {
  @override
  List<String> dependsOn(BuildContext context) => null;

  @override
  Duration durationToHomePageDateUpdate() => null;

  @override
  // Only used here so not exported to keys class
  String featureKey = SubjectsKeys.subjects;

  @override
  FeatureWidget getFeatureWidget(Widget child) => SubjectsWidget(
        feature: this,
        key: ValueKey(featureKey),
        child: child,
      );

  @override
  DateTime getHomePageDate() => null;

  @override
  InfoCard getInfoCard(DateTime date, double maxHeight) => null;

  @override
  Widget getPage() => null;

  @override
  SubjectsLoader loader = SubjectsLoader();

  @override
  String name;

  @override
  NotificationsHandler notificationsHandler;

  @override
  Subscription subscribeToDataUpdates(
          EventBus eventBus, Function(ChangedEvent) callback) =>
      eventBus.respond<SubjectsUpdateEvent>(callback);

  @override
  TagsHandler tagsHandler;

  @override
  List<Option> extraSettings;

  @override
  bool hasGUI = false;
}

// ignore: public_member_api_docs
class SubjectsWidget extends FeatureWidget<SubjectsFeature> {
  // ignore: public_member_api_docs
  const SubjectsWidget(
      {@required Widget child, @required SubjectsFeature feature, Key key})
      : super(child: child, feature: feature, key: key);

  /// Find the closest [SubjectsWidget] from ancestor tree.
  static SubjectsWidget of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<SubjectsWidget>();
}
