import 'package:flutter/material.dart';

/// The feature widget must be in the top off the app,
/// because all widgets below need access to this feature via the .of(context) function
///
/// The function
/// ```dart
///   static FeatureWidget of(BuildContext context) {
///     return context.dependOnInheritedWidgetOfExactType<FeatureWidget>();
///   }
/// ```
/// must always be defined
/// {@end-tool}
abstract class FeatureWidget<Feature> extends InheritedWidget {
  // ignore: public_member_api_docs
  const FeatureWidget(
      {@required this.feature, @required Widget child, @required Key key})
      : super(child: child, key: key);

  // ignore: public_member_api_docs
  final Feature feature;

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => false;

  /// Find the closest [FeatureWidget] from ancestor tree.
  static FeatureWidget of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<FeatureWidget>();
}
