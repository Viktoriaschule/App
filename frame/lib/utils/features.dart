import 'package:flutter/material.dart';
import 'package:utils/utils.dart';

// ignore: public_member_api_docs
class Features extends InheritedWidget {
  // ignore: public_member_api_docs
  const Features({@required Widget child, @required this.features})
      : super(child: child);

  /// All pages in this app
  final List<Feature> features;

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => false;

  /// Find the closest [Features] from ancestor tree.
  static Features of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<Features>();
}
