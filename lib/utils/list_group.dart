import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:ginko/utils/bottom_navigation.dart';

// ignore: public_member_api_docs
class ListGroup extends StatelessWidget {
  // ignore: public_member_api_docs
  const ListGroup({
    @required this.title,
    @required this.children,
    this.actions,
    this.heroId,
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

  // ignore: public_member_api_docs
  final String heroId;

  // ignore: public_member_api_docs
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final actions = this.actions ?? [];
    final content = Container(
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
                      color: Colors.black87,
                      fontSize: 18,
                    ),
                  ),
                ),
                if (counter > 0)
                  Expanded(
                    flex: 15,
                    child: Center(
                      child: Container(
                        margin: EdgeInsets.only(right: 9),
                        child: Text(
                          '+${counter >= 10 ? counter : '$counter'}',
                          style: TextStyle(
                            fontWeight: FontWeight.w100,
                            color: Colors.black87,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          ...children,
          Container(
            height: 10,
          ),
        ],
      ),
    );
    return Card(
      shape: BeveledRectangleBorder(
        borderRadius: BorderRadius.circular(0),
      ),
      elevation: 5,
      margin: EdgeInsets.all(10),
      child: Column(
        children: <Widget>[
          Stack(
            children: <Widget>[
              if (heroId != null)
                Hero(
                  tag: heroId ?? this,
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
          if (actions.isNotEmpty && heroId != null)
            Hero(
              tag: '$heroId-navigation',
              child: Material(
                type: MaterialType.transparency,
                child: BottomNavigation(actions: actions),
              ),
            )
          else if (actions.isNotEmpty)
            BottomNavigation(actions: actions),
        ],
      ),
    );
  }
}
