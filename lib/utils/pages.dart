import 'package:flutter/material.dart';
import 'package:viktoriaapp/models/models.dart';

// ignore: public_member_api_docs
class Pages extends InheritedWidget {
  // ignore: public_member_api_docs
  Pages({@required Widget child}) : super(child: child);

  /// Checks if any page is loading
  bool get isLoading => pages.keys
      .map((key) => pages[key].isLoading)
      .reduce((v1, v2) => v1 || v2);

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
  Page(this.title, {this.isLoading = false});

  // ignore: public_member_api_docs
  final String title;

  // ignore: public_member_api_docs
  bool isLoading;
}
