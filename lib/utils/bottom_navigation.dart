import 'package:flutter/material.dart';
import 'package:ginko/utils/theme.dart';

// ignore: public_member_api_docs
class NavigationAction {
  // ignore: public_member_api_docs
  NavigationAction(this.icon, this.onTap);

  // ignore: public_member_api_docs
  final IconData icon;

  // ignore: public_member_api_docs
  final VoidCallback onTap;
}

// ignore: public_member_api_docs
class BottomNavigation extends StatelessWidget {
  // ignore: public_member_api_docs
  const BottomNavigation({@required this.actions});

  // ignore: public_member_api_docs
  final List<NavigationAction> actions;

  @override
  Widget build(BuildContext context) => Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            width: 1,
            color: Color.fromARGB(50, 0, 0, 0),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          ...actions.map((action) {
            final borderRight = actions.indexOf(action) < actions.length - 1;
            return Expanded(
              child: InkWell(
                onTap: action.onTap,
                child: Container(
                  height: 45,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: borderRight
                        ? Border(
                            right: BorderSide(
                              width: 1,
                              color: Color.fromARGB(50, 0, 0, 0),
                            ),
                          )
                        : null,
                  ),
                  child: Icon(
                    action.icon,
                    color: textColorLight(context)
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
}
