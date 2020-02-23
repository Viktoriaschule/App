import 'package:flutter/material.dart';
import 'package:flutter_event_bus/flutter_event_bus.dart';
import 'package:viktoriaapp/models/keys.dart';
import 'package:viktoriaapp/utils/events.dart';
import 'package:viktoriaapp/utils/pages.dart';
import 'package:viktoriaapp/utils/theme.dart';
import 'package:viktoriaapp/widgets/custom_hero.dart';
import 'package:viktoriaapp/widgets/custom_linear_progress_indicator.dart';

// ignore: public_member_api_docs
class CustomAppBar extends PreferredSize {
  // ignore: public_member_api_docs
  const CustomAppBar({
    @required this.title,
    @required this.pageKey,
    this.actions = const [],
    this.sliver = false,
    this.isLeading = true,
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
  final String pageKey;

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
              color: textColor(context),
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
      child: LoadingProgress(
        height: 3,
        pageKey: pageKey,
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
      );
    }
    return AppBar(
      title: _title,
      actions: _actions,
      elevation: 0,
      bottom: _bottom,
      titleSpacing: isLeading ? 0 : NavigationToolbar.kMiddleSpacing,
    );
  }
}

// ignore: public_member_api_docs
class LoadingProgress extends StatefulWidget {
  // ignore: public_member_api_docs
  const LoadingProgress({
    @required this.pageKey,
    this.height,
    Key key,
  }) : super(key: key);

  // ignore: public_member_api_docs
  final String pageKey;

  // ignore: public_member_api_docs
  final double height;

  @override
  State<StatefulWidget> createState() => LoadingProgressState();
}

// ignore: public_member_api_docs
class LoadingProgressState extends Interactor<LoadingProgress> {
  // ignore: public_member_api_docs
  bool isLoading;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    isLoading = Pages.of(context).isLoading(widget.pageKey);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: Duration(milliseconds: 200),
      opacity: isLoading ? 1 : 0,
      child: CustomLinearProgressIndicator(
        height: widget.height,
        backgroundColor: Theme.of(context).primaryColor,
      ),
    );
  }

  @override
  Subscription subscribeEvents(EventBus eventBus) =>
      eventBus.respond<LoadingStatusChangedEvent>((event) {
        if (widget.pageKey == Keys.home) {
          setState(() {
            isLoading = Pages.of(context).isLoading(widget.pageKey);
          });
        } else if (event.key == widget.pageKey) {
          setState(
              () => isLoading = Pages.of(context).isLoading(widget.pageKey));
        }
      });
}
