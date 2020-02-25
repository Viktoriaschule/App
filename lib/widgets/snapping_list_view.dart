import 'dart:math';

import 'package:flutter/widgets.dart';

// ignore: public_member_api_docs
class SnappingListView extends StatefulWidget {
  // ignore: public_member_api_docs
  const SnappingListView({
    @required this.children,
    @required this.itemExtent,
    this.scrollDirection,
    this.controller,
    this.onItemChanged,
    this.padding = const EdgeInsets.all(0),
  })  : assert(itemExtent > 0, 'itemExtent needs to be greater than 0.0'),
        itemCount = null,
        itemBuilder = null;

  // ignore: public_member_api_docs
  const SnappingListView.builder({
    @required this.itemBuilder,
    @required this.itemExtent,
    this.scrollDirection,
    this.controller,
    this.itemCount,
    this.onItemChanged,
    this.padding = const EdgeInsets.all(0),
  })  : assert(itemExtent > 0, 'itemExtent needs to be greater than 0.0'),
        children = null;

  // ignore: public_member_api_docs
  final Axis scrollDirection;

  // ignore: public_member_api_docs
  final ScrollController controller;

  // ignore: public_member_api_docs
  final IndexedWidgetBuilder itemBuilder;

  // ignore: public_member_api_docs
  final List<Widget> children;

  // ignore: public_member_api_docs
  final int itemCount;

  // ignore: public_member_api_docs
  final double itemExtent;

  // ignore: public_member_api_docs
  final ValueChanged<int> onItemChanged;

  // ignore: public_member_api_docs
  final EdgeInsets padding;

  @override
  _SnappingListViewState createState() => _SnappingListViewState();
}

class _SnappingListViewState extends State<SnappingListView> {
  int _lastItem = 0;

  @override
  Widget build(BuildContext context) {
    final startPadding = widget.scrollDirection == Axis.horizontal
        ? widget.padding.left
        : widget.padding.top;
    final scrollPhysics = SnappingListScrollPhysics(
        mainAxisStartPadding: startPadding, itemExtent: widget.itemExtent);
    final listView = widget.children != null
        ? ListView(
            scrollDirection: widget.scrollDirection,
            controller: widget.controller,
            itemExtent: widget.itemExtent,
            physics: scrollPhysics,
            padding: widget.padding,
            children: widget.children,
          )
        : ListView.builder(
            scrollDirection: widget.scrollDirection,
            controller: widget.controller,
            itemBuilder: widget.itemBuilder,
            itemCount: widget.itemCount,
            itemExtent: widget.itemExtent,
            physics: scrollPhysics,
            padding: widget.padding,
          );
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification.depth == 0 &&
            widget.onItemChanged != null &&
            notification is ScrollUpdateNotification) {
          final currItem =
              (notification.metrics.pixels - startPadding) ~/ widget.itemExtent;
          if (currItem != _lastItem) {
            _lastItem = currItem;
            widget.onItemChanged(currItem);
          }
        }
        return false;
      },
      child: listView,
    );
  }
}

// ignore: public_member_api_docs
class SnappingListScrollPhysics extends ScrollPhysics {
  // ignore: public_member_api_docs
  const SnappingListScrollPhysics({
    @required this.itemExtent,
    ScrollPhysics parent,
    this.mainAxisStartPadding = 0.0,
  }) : super(parent: parent);

  // ignore: public_member_api_docs
  final double mainAxisStartPadding;

  // ignore: public_member_api_docs
  final double itemExtent;

  @override
  SnappingListScrollPhysics applyTo(ScrollPhysics ancestor) =>
      SnappingListScrollPhysics(
        parent: buildParent(ancestor),
        mainAxisStartPadding: mainAxisStartPadding,
        itemExtent: itemExtent,
      );

  double _getItem(ScrollPosition position) =>
      (position.pixels - mainAxisStartPadding) / itemExtent;

  double _getPixels(ScrollPosition position, double item) =>
      min(item * itemExtent, position.maxScrollExtent);

  double _getTargetPixels(
      ScrollPosition position, Tolerance tolerance, double velocity) {
    double item = _getItem(position);
    if (velocity < -tolerance.velocity) {
      item -= 0.5;
    } else if (velocity > tolerance.velocity) {
      item += 0.5;
    }
    return _getPixels(position, item.roundToDouble());
  }

  @override
  Simulation createBallisticSimulation(
      ScrollMetrics position, double velocity) {
    // If we're out of range and not headed back in range, defer to the parent
    // ballistics, which should put us back in range at a page boundary.
    if ((velocity <= 0.0 && position.pixels <= position.minScrollExtent) ||
        (velocity >= 0.0 && position.pixels >= position.maxScrollExtent)) {
      return super.createBallisticSimulation(position, velocity);
    }
    final Tolerance tolerance = this.tolerance;
    final double target = _getTargetPixels(position, tolerance, velocity);
    if (target != position.pixels) {
      return ScrollSpringSimulation(spring, position.pixels, target, velocity,
          tolerance: tolerance);
    }
    return null;
  }

  @override
  bool get allowImplicitScrolling => false;
}
