import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:viktoriaapp/models/keys.dart';
import 'package:viktoriaapp/utils/bottom_navigation.dart';
import 'package:viktoriaapp/utils/custom_hero.dart';
import 'package:viktoriaapp/utils/theme.dart';

// ignore: public_member_api_docs
class ListGroup extends StatelessWidget {
  // ignore: public_member_api_docs
  const ListGroup({
    @required this.title,
    @required this.children,
    this.actions,
    this.heroId,
    this.heroIdNavigation,
    this.center = false,
    this.counter = 0,
    this.onTap,
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

  @override
  Widget build(BuildContext context) {
    final actions = this.actions ?? [];
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
                  flex: 85,
                  child: Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w100,
                      color: textColor(context),
                      fontSize: 18,
                    ),
                  ),
                ),
                if (counter > 0)
                  Text(
                    '+${counter >= 10 ? counter : '$counter'}',
                    style: TextStyle(
                      fontWeight: FontWeight.w100,
                      color: textColor(context),
                      fontSize: 18,
                    ),
                  ),
              ],
            ),
          ),
          ...children,
        ],
      ),
    );
    return Card(
      margin: EdgeInsets.all(10),
      child: Column(
        children: <Widget>[
          Stack(
            children: <Widget>[
              if (heroId != null)
                CustomHero(
                  tag: heroId,
                  child: Material(
                    type: MaterialType.transparency,
                    child: content,
                  ),
                )
              else
                content,
              Positioned.fill(
                child: InkWell(
                  onTap:
                      onTap ?? (actions.isNotEmpty ? actions[0].onTap : null),
                  child: Container(),
                ),
              ),
            ],
          ),
          if (actions.isNotEmpty &&
              (heroId != null || heroIdNavigation != null))
            CustomHero(
              tag: Keys.navigation(heroIdNavigation ?? heroId),
              child: Material(
                type: MaterialType.transparency,
                child: BottomNavigation(
                  actions: actions,
                  forceBorderTop: true,
                ),
              ),
            )
          else if (actions.isNotEmpty)
            BottomNavigation(
              actions: actions,
              forceBorderTop: true,
            ),
        ],
      ),
    );
  }
}
