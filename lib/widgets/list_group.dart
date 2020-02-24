import 'package:after_layout/after_layout.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_event_bus/flutter_event_bus.dart';
import 'package:viktoriaapp/models/keys.dart';
import 'package:viktoriaapp/utils/events.dart';
import 'package:viktoriaapp/utils/pages.dart';
import 'package:viktoriaapp/utils/theme.dart';
import 'package:viktoriaapp/widgets/custom_bottom_navigation.dart';
import 'package:viktoriaapp/widgets/custom_circular_progress_indicator.dart';
import 'package:viktoriaapp/widgets/custom_hero.dart';

// ignore: public_member_api_docs
class ListGroup extends StatefulWidget {
  // ignore: public_member_api_docs
  const ListGroup({
    @required this.title,
    @required this.children,
    this.pageKey,
    this.actions,
    this.heroId,
    this.heroIdNavigation,
    this.center = false,
    this.counter = 0,
    this.onTap,
    this.showNavigation = true,
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
  final String pageKey;

  @override
  _ListGroupState createState() => _ListGroupState();
}

class _ListGroupState extends Interactor<ListGroup>
    with AfterLayoutMixin<ListGroup> {
  bool _isLoading = false;

  @override
  Subscription subscribeEvents(EventBus eventBus) =>
      eventBus.respond<LoadingStatusChangedEvent>((event) async {
        if (event.key == widget.pageKey) {
          setState(() {
            _isLoading = Pages.of(context).isLoading(widget.pageKey);
          });
        }
      });

  @override
  void afterFirstLayout(BuildContext context) {
    setState(() {
      _isLoading = Pages.of(context).isLoading(widget.pageKey);
    });
  }

  @override
  Widget build(BuildContext context) {
    final actions = widget.actions ?? [];
    final content = Container(
      padding: EdgeInsets.only(bottom: 10),
      child: Column(
        children: [
          Container(
            height: 40,
            margin: EdgeInsets.only(bottom: 10),
            padding: EdgeInsets.only(left: 20, right: 10),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    widget.title,
                    style: TextStyle(
                      fontWeight: FontWeight.w100,
                      color: ThemeWidget.of(context).textColor,
                      fontSize: 18,
                    ),
                  ),
                ),
                Container(
                  width: 31,
                  child: AnimatedCrossFade(
                    duration: Duration(milliseconds: 100),
                    firstChild: Container(
                      margin: EdgeInsets.all(5.5),
                      child: CustomCircularProgressIndicator(
                        height: 20,
                        width: 20,
                      ),
                    ),
                    secondChild: widget.counter > 0
                        ? Text(
                            '+${widget.counter}',
                            style: TextStyle(
                              fontWeight: FontWeight.w100,
                              color: ThemeWidget.of(context).textColor,
                              fontSize: 18,
                            ),
                          )
                        : Container(),
                    crossFadeState: widget.pageKey != null && _isLoading
                        ? CrossFadeState.showFirst
                        : CrossFadeState.showSecond,
                  ),
                ),
              ],
            ),
          ),
          ...widget.children,
        ],
      ),
    );
    return Card(
      margin: EdgeInsets.all(10),
      child: Column(
        children: <Widget>[
          Stack(
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
              if ((widget.onTap ??
                      (actions.isNotEmpty ? actions[0].onTap : null)) !=
                  null)
                Positioned.fill(
                  child: InkWell(
                    onTap: widget.onTap ??
                        (actions.isNotEmpty ? actions[0].onTap : null),
                    child: Container(),
                  ),
                ),
            ],
          ),
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
