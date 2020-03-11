import 'package:flutter/material.dart';
import 'package:utils/utils.dart';

/// Does all feature managements
class Features extends StatelessWidget {
  // ignore: public_member_api_docs
  const Features({
    @required this.child,
    @required this.features,
  });

  /// The child of this widget
  final Widget child;

  /// All pages in this app
  final List<Feature> features;

  /// All feature widget must be in a tree above the app,
  /// because the features need access via the
  Widget _getFeatureWidget(int index) {
    if (index < features.length) {
      return features[index].getFeatureWidget(_getFeatureWidget(index + 1));
    }
    return FeaturesWidget(
      features: features,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) => _getFeatureWidget(0);
}

// ignore: public_member_api_docs
class FeaturesWidget extends InheritedWidget {
  // ignore: public_member_api_docs
  FeaturesWidget({
    @required Widget child,
    @required this.features,
  }) : super(child: child) {
    for (final feature in features) {
      _featuresMap[feature.featureKey] = feature;
    }
  }

  /// All pages in this app
  final List<Feature> features;

  /// All features in a map
  final Map<String, Feature> _featuresMap = {};

  /// Returns a feature with the given feature key
  Feature getFeature(String key) => _featuresMap[key];

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => false;

  /// Find the closest [FeaturesWidget] from ancestor tree.
  static FeaturesWidget of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<FeaturesWidget>();
}
