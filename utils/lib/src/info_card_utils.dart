import 'package:flutter/material.dart';

import 'screen_sizes.dart';

// ignore: public_member_api_docs
class InfoCardUtils {
  // ignore: public_member_api_docs
  InfoCardUtils(this.context, this.date);

  // ignore: public_member_api_docs
  final BuildContext context;

  // ignore: public_member_api_docs
  final DateTime date;

  /// Get the number of items to display
  int get cut {
    if (size == ScreenSize.small) {
      return 3;
    }
    final c = _calculateCut(context, size == ScreenSize.middle ? 3 : 2);
    if (c < 1) {
      return 1;
    }
    return c;
  }

  /// Get the screen size
  ScreenSize get size => getScreenSize(MediaQuery.of(context).size.width);

  /// Get the weekday
  int get weekday => date.weekday - 1;

  int _calculateCut(BuildContext context, int parts) =>
      _calculateHeight(context, parts) ~/ 60;

  double _calculateHeight(BuildContext context, int parts) {
    final viewHeight = MediaQuery.of(context).size.height;
    final tabBarHeight = TabBar(
      tabs: const [],
    ).preferredSize.height;
    const padding = 30;
    return (viewHeight - _screenPadding) / parts - tabBarHeight - padding;
  }

  final _screenPadding = 110;
}
