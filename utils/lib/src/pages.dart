import 'package:flutter/material.dart';

import 'keys.dart';

// ignore: public_member_api_docs
class Pages extends InheritedWidget {
  // ignore: public_member_api_docs
  Pages({@required Widget child}) : super(child: child);

  final Map<String, bool> _loading = {};

  /// Check if a loader is loading
  bool isLoading(List<String> keys) =>
      keys.isNotEmpty &&
      keys.map((key) => _loading[key] ?? false).reduce((v1, v2) => v1 || v2);

  /// Sets if a loader is loading
  void setLoading(String key, bool isLoading) => _loading[key] = isLoading;

  /// All pages in this app
  final Map<String, Page> pages = {
    '${Keys.substitutionPlan}': Page('Vertretungsplan'),
    '${Keys.cafetoria}': Page('Cafétoria'),
    '${Keys.aiXformation}': Page('AiXformation'),
    '${Keys.calendar}': Page('Kalender'),
    '${Keys.settings}': Page('Einstellungen'),
    '${Keys.timetable}': Page('Stundenplan'),
    '${Keys.home}': Page('Startseite'),
  };

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => false;

  /// Find the closest [Pages] from ancestor tree.
  static Pages of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<Pages>();
}

// ignore: public_member_api_docs
class Page {
  // ignore: public_member_api_docs
  Page(this.title);

  // ignore: public_member_api_docs
  final String title;
}
