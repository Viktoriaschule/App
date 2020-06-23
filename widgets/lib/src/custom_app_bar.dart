import 'package:after_layout/after_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_event_bus/flutter_event_bus.dart';
import 'package:utils/utils.dart';

import 'custom_hero.dart';
import 'custom_linear_progress_indicator.dart';

// ignore: public_member_api_docs
class CustomAppBar extends PreferredSize {
  // ignore: public_member_api_docs
  const CustomAppBar({
    @required this.title,
    @required this.loadingKeys,
    this.actions = const [],
    this.sliver = false,
    this.isLeading = true,
    this.elevation = 0,
  });

  // ignore: public_member_api_docs
  final String title;

  // ignore: public_member_api_docs
  final List<Widget> actions;

  // ignore: public_member_api_docs
  final bool sliver;

  // ignore: public_member_api_docs
  final bool isLeading;

  // ignore: public_member_api_docs
  final List<String> loadingKeys;

  // ignore: public_member_api_docs
  final double elevation;

  @override
  Size get preferredSize => AppBar().preferredSize;

  @override
  Widget build(BuildContext context) {
    final _title = CustomHero(
      tag: Keys.title,
      child: Material(
        type: MaterialType.transparency,
        child: Container(
          width: 200,
          child: Text(
            title,
            style: TextStyle(
              color: ThemeWidget.of(context).textColor,
              fontWeight: FontWeight.w100,
              fontSize: 22,
            ),
          ),
        ),
      ),
    );
    final _actions = actions
        .map((action) => CustomHero(
              tag: actions.last == action ? Keys.actionMain : action,
              child: Material(type: MaterialType.transparency, child: action),
            ))
        .toList();
    final _bottom = PreferredSize(
      preferredSize: Size.fromHeight(3),
      child: LinearLoadingProgress(
        height: 3,
        loadingKeys: loadingKeys,
      ),
    );
    if (sliver) {
      return SliverAppBar(
        title: _title,
        actions: _actions,
        floating: false,
        pinned: true,
        bottom: _bottom,
        titleSpacing: isLeading ? 0 : NavigationToolbar.kMiddleSpacing,
        automaticallyImplyLeading: isLeading,
        elevation: elevation,
      );
    }
    return AppBar(
      title: _title,
      actions: _actions,
      elevation: elevation,
      bottom: _bottom,
      titleSpacing: isLeading ? 0 : NavigationToolbar.kMiddleSpacing,
      automaticallyImplyLeading: isLeading,
    );
  }
}

// ignore: public_member_api_docs
class LinearLoadingProgress extends StatefulWidget {
  // ignore: public_member_api_docs
  const LinearLoadingProgress({
    @required this.loadingKeys,
    this.height,
    Key key,
  }) : super(key: key);

  // ignore: public_member_api_docs
  final List<String> loadingKeys;

  // ignore: public_member_api_docs
  final double height;

  @override
  State<StatefulWidget> createState() => LinearLoadingProgressState();
}

// ignore: public_member_api_docs
class LinearLoadingProgressState extends Interactor<LinearLoadingProgress>
    with AfterLayoutMixin<LinearLoadingProgress> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) => AnimatedOpacity(
        duration: Duration(milliseconds: 200),
        opacity: _isLoading ? 1 : 0,
        child: CustomLinearProgressIndicator(
          height: widget.height,
          backgroundColor: Theme.of(context).primaryColor,
        ),
      );

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
}
