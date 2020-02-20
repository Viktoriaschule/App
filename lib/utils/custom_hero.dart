import 'package:flutter/material.dart';
import 'package:viktoriaapp/plugins/platform/platform.dart';

// ignore: public_member_api_docs
class CustomHero extends StatelessWidget {
  // ignore: public_member_api_docs
  const CustomHero({
    @required this.child,
    this.tag,
    Key key,
  }) : super(key: key);

  // ignore: public_member_api_docs
  final Widget child;

  /// If the tag is null, the hero will be deactivated
  final dynamic tag;

  /// Disables all heros for web
  bool get isEnabled => tag != null && !Platform().isWeb;

  @override
  Widget build(BuildContext context) => isEnabled
      ? Hero(
          tag: tag,
          child: child,
        )
      : child;
}
