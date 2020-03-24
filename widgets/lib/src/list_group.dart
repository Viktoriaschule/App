import 'package:after_layout/after_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_event_bus/flutter_event_bus.dart';
import 'package:utils/utils.dart';
import 'package:widgets/widgets.dart';

import 'custom_bottom_navigation.dart';
import 'custom_card.dart';
import 'custom_circular_progress_indicator.dart';
import 'custom_hero.dart';

// ignore: public_member_api_docs
class ListGroup extends StatefulWidget {
  // ignore: public_member_api_docs
  const ListGroup({
    @required this.title,
    @required this.children,
    this.loadingKeys = const [],
    this.actions,
    this.heroId,
    this.heroIdNavigation,
    this.center = false,
    this.counter = 0,
    this.onTap,
    this.showNavigation = true,
    this.doRowsHandleClick = false,
    this.maxHeight,
    Key key,
  }) : super(key: key);

  // ignore: public_member_api_docs
  final List<Widget> children;

  // ignore: public_member_api_docs
  final List<NavigationAction> actions;

  // ignore: public_member_api_docs
  final String title;

  // ignore: public_member_api_docs
  final bool center;

  // ignore: public_member_api_docs
  final int counter;

  /// The [heroId] for an optional hero animation.
  ///
  /// The hero animation is only added if the [heroId] is not null
  final String heroId;

  /// If this is set, [heroIdNavigation] will be used instead of [heroId] for the navigation bar
  final String heroIdNavigation;

  // ignore: public_member_api_docs
  final VoidCallback onTap;

  // ignore: public_member_api_docs
  final bool showNavigation;

  // ignore: public_member_api_docs
  final List<String> loadingKeys;

  // ignore: public_member_api_docs
  final bool doRowsHandleClick;

  // ignore: public_member_api_docs
  final double maxHeight;

  @override
  _ListGroupState createState() => _ListGroupState();
}

class _ListGroupState extends Interactor<ListGroup>
    with AfterLayoutMixin<ListGroup> {
  bool _isLoading = false;

  @override
  Subscription subscribeEvents(EventBus eventBus) =>
      eventBus.respond<LoadingStatusChangedEvent>((event) async {
        if (widget.loadingKeys.contains(event.key)) {
          setState(() {
            _isLoading = LoadingState.of(context).isLoading(widget.loadingKeys);
          });
        }
      });

  @override
  void afterFirstLayout(BuildContext context) {
    setState(() {
      _isLoading = LoadingState.of(context).isLoading(widget.loadingKeys);
    });
  }

  @override
  Widget build(BuildContext context) {
    final actions = widget.actions ?? [];
    final allHeight = widget.maxHeight != null
        ? widget.maxHeight - (actions != null && actions.isNotEmpty ? 64.5 : 0)
        : null;
    final contentHeight = widget.maxHeight != null ? allHeight - 39.5 : null;
    final content = Container(
      height: allHeight,
      child: Column(
        children: [
          Container(
            height: 41,
            child: InkWell(
              onTap: widget.doRowsHandleClick
                  ? widget.onTap ??
                      (actions.isNotEmpty ? actions[0].onTap : null)
                  : null,
              child: Container(
                padding: EdgeInsets.only(left: 10, right: 10),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: 31),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.only(top: 10, bottom: 10),
                          child: Text(
                            widget.title,
                            style: TextStyle(
                              fontWeight: FontWeight.w100,
                              color: ThemeWidget.of(context).textColor,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(top: 10, bottom: 10),
                        width: 31,
                        height: 41,
                        child: Stack(
                          children: [
                            AnimatedOpacity(
                              duration: Duration(milliseconds: 100),
                              opacity: widget.loadingKeys != null && _isLoading
                                  ? 1
                                  : 0,
                              child: Center(
                                child: CustomCircularProgressIndicator(
                                  height: 20,
                                  width: 20,
                                ),
                              ),
                            ),
                            AnimatedOpacity(
                              duration: Duration(milliseconds: 100),
                              opacity: widget.loadingKeys != null && _isLoading
                                  ? 0
                                  : 1,
                              child: Center(
                                child: Text(
                                  widget.counter > 0
                                      ? '+${widget.counter}'
                                      : '',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w100,
                                    color: ThemeWidget.of(context).textColor,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (widget.maxHeight != null)
            Column(
              children: [
                for (int i = 0; i < contentHeight ~/ 60; i++)
                  if (i < widget.children.length)
                    Container(
                      height: 60,
                      child: widget.children[i],
                    )
              ],
            )
          else
            ...widget.children,
        ],
      ),
    );
    final stack = Stack(
      children: <Widget>[
        if (widget.heroId != null && widget.showNavigation)
          CustomHero(
            tag: widget.heroId,
            child: Material(
              type: MaterialType.transparency,
              child: content,
            ),
          )
        else
          content,
        if ((widget.onTap ?? (actions.isNotEmpty ? actions[0].onTap : null)) !=
                null &&
            !widget.doRowsHandleClick)
          Positioned.fill(
            child: InkWell(
              onTap: widget.onTap ??
                  (actions.isNotEmpty ? actions[0].onTap : null),
              child: Container(),
            ),
          ),
      ],
    );
    return CustomCard(
      margin: EdgeInsets.all(10),
      child: Column(
        children: <Widget>[
          stack,
          if (actions.isNotEmpty &&
              (widget.heroId != null || widget.heroIdNavigation != null) &&
              widget.showNavigation)
            CustomHero(
              tag: Keys.navigation(widget.heroIdNavigation ?? widget.heroId),
              child: Material(
                type: MaterialType.transparency,
                child: CustomBottomNavigation(
                  actions: actions,
                  forceBorderTop: true,
                  inCard: true,
                ),
              ),
            )
          else if (actions.isNotEmpty && widget.showNavigation)
            CustomBottomNavigation(
              actions: actions,
              forceBorderTop: true,
              inCard: true,
            ),
        ],
      ),
    );
  }
}
