import 'package:flutter/material.dart';

// ignore: public_member_api_docs
class LoadingState extends InheritedWidget {
  // ignore: public_member_api_docs
  LoadingState({
    @required Widget child,
  }) : super(child: child);

  final Map<String, bool> _loading = {};

  /// Check if a loader is loading
  bool isLoading(List<String> keys) =>
      keys.isNotEmpty &&
      keys.map((key) => _loading[key] ?? false).reduce((v1, v2) => v1 || v2);

  /// Sets if a loader is loading
  void setLoading(String key, bool isLoading) => _loading[key] = isLoading;

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => false;

  /// Find the closest [LoadingState] from ancestor tree.
  static LoadingState of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<LoadingState>();
}
