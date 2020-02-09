import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

// ignore: public_member_api_docs
class ListGroupHeader extends StatelessWidget {
  // ignore: public_member_api_docs
  const ListGroupHeader({
    @required this.title,
    this.center = false,
    this.counter = 0,
    this.onTap,
    Key key,
  }) : super(key: key);

  // ignore: public_member_api_docs
  final String title;

  // ignore: public_member_api_docs
  final bool center;

  // ignore: public_member_api_docs
  final int counter;

  // ignore: public_member_api_docs
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: <Widget>[
                Positioned(
                  bottom: 10,
                  child: Container(
                    width: constraints.maxWidth,
                    height: 10,
                    decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black,
                            blurRadius: 10,
                            offset: Offset(0, -5)
                          )
                        ]),
                    child: Container(),
                  ),
                ),
                Container(
                  height: 50,
                  color: Theme.of(context).primaryColor,
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
              ],
            );
          },
        ),
      );
}
