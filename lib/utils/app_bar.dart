import 'package:flutter/material.dart';
import 'package:viktoriaapp/models/keys.dart';
import 'package:viktoriaapp/utils/custom_hero.dart';
import 'package:viktoriaapp/utils/theme.dart';

// ignore: public_member_api_docs
class CustomAppBar extends PreferredSize {
  // ignore: public_member_api_docs
  const CustomAppBar(
      {@required this.title, this.actions, this.bottom, this.sliver = false});

  // ignore: public_member_api_docs
  final String title;

  // ignore: public_member_api_docs
  final List<Widget> actions;

  // ignore: public_member_api_docs
  final bool sliver;

  // ignore: public_member_api_docs
  final PreferredSize bottom;

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
    if (sliver) {
      return SliverAppBar(
        title: _title,
        actions: _actions,
        floating: false,
        pinned: true,
        bottom: bottom,
      );
    }
    return AppBar(
      title: _title,
      actions: _actions,
      elevation: 0,
      bottom: bottom,
    );
  }
}
