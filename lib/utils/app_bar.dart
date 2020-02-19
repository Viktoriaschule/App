import 'package:flutter/material.dart';
import 'package:viktoriaapp/models/keys.dart';
import 'package:viktoriaapp/plugins/platform/platform.dart';
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
    final _title = Hero(
      tag: !Platform().isWeb ? Keys.title : this,
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
        .map((action) => Hero(
              tag: !Platform().isWeb
                  ? (actions.last == action ? Keys.actionMain : action)
                  : hashCode,
              child: Material(type: MaterialType.transparency, child: action),
            ))
        .toList();
    if (sliver) {
      return SliverAppBar(
        title: _title,
        actions: _actions,
        automaticallyImplyLeading: false,
        floating: false,
        pinned: true,
        bottom: bottom,
      );
    }
    return AppBar(
      title: _title,
      actions: _actions,
      automaticallyImplyLeading: false,
      elevation: 0,
      bottom: bottom,
    );
  }
}
