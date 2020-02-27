import 'dart:math';

import 'package:flutter/material.dart';
import 'package:viktoriaapp/models/models.dart';
import 'package:viktoriaapp/widgets/custom_refresh_indicator.dart';

/// A list view that allows to scroll a parent after reach the borders
class CustomListView extends StatefulWidget {
  // ignore: public_member_api_docs
  const CustomListView({
    @required this.scrollControllerParent,
    @required this.children,
    this.height,
    this.isTop = true,
    this.loadOnline,
    Key key,
  }) : super(key: key);

  /// The scroll controller for the parent scroll view
  final ScrollController scrollControllerParent;

  // ignore: public_member_api_docs
  final List<Widget> children;

  /// The fix height for this list view
  final double height;

  /// Whether the list view is in the top or not
  final bool isTop;

  // ignore: public_member_api_docs
  final Future<StatusCodes> Function() loadOnline;

  @override
  _CustomListViewState createState() => _CustomListViewState();
}

class _CustomListViewState extends State<CustomListView>
    with SingleTickerProviderStateMixin {
  bool isDragging;

  /// Handle all scroll updates
  bool _scrollUpdate(ScrollNotification notification) {
    // Only use scroll notifications from direct children
    if (notification.depth != 0) {
      return false;
    }
    // Start and stop the dragging process
    if (notification is ScrollStartNotification) {
      isDragging = true;
    } else if (notification is ScrollEndNotification) {
      isDragging = false;
    }

    // Handle the overscroll
    if (notification is OverscrollNotification && isDragging) {
      // Get the current parent scroll offset
      final current = widget.scrollControllerParent.offset;

      // Get the new offset. The offset must be min zero and max the page height
      final double newOffset =
          max(min(current + notification.overscroll, widget.height), 0);

      // Update the parent list view
      widget.scrollControllerParent.jumpTo(newOffset);
    }
    return false;
  }

  // Block the overscroll indicator on the correct side
  bool _onOverscroll(OverscrollIndicatorNotification notification) {
    // If this is the top widget, block it at the bottom and in the other case on the top
    if (notification.leading != widget.isTop) {
      notification.disallowGlow();
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    Widget child = ListView(
      padding: EdgeInsets.only(bottom: 20),
      children: widget.children,
    );
    if (widget.loadOnline != null) {
      child = CustomRefreshIndicator(
        loadOnline: widget.loadOnline,
        child: child,
      );
    }
    return SizedBox(
      height: widget.height,
      child: NotificationListener<ScrollNotification>(
        onNotification: _scrollUpdate,
        child: NotificationListener<OverscrollIndicatorNotification>(
          onNotification: _onOverscroll,
          child: child,
        ),
      ),
    );
  }
}
