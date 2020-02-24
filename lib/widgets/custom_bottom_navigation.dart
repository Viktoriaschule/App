import 'package:flutter/material.dart';
import 'package:viktoriaapp/utils/theme.dart';

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
class CustomBottomNavigation extends StatelessWidget {
  // ignore: public_member_api_docs
  const CustomBottomNavigation({
    @required this.actions,
    this.forceBorderTop = false,
    this.inCard = false,
  });

  // ignore: public_member_api_docs
  final List<NavigationAction> actions;

  // ignore: public_member_api_docs
  final bool forceBorderTop;

  // ignore: public_member_api_docs
  final bool inCard;

  @override
  Widget build(BuildContext context) => Container(
        decoration:
            MediaQuery.of(context).platformBrightness == Brightness.light ||
                    forceBorderTop
                ? BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        width: 1,
                        color: Color.fromARGB(50, 0, 0, 0),
                      ),
                    ),
                  )
                : null,
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
                      color: MediaQuery.of(context).platformBrightness ==
                                  Brightness.dark &&
                              !inCard
                          ? darkColor
                          : null,
                    ),
                    child: Icon(
                      action.icon,
                      color: ThemeWidget.of(context).textColorLight(),
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      );
}
