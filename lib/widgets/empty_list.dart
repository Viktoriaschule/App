import 'package:flutter/material.dart';
import 'package:viktoriaapp/utils/theme.dart';

// ignore: public_member_api_docs
class EmptyList extends StatelessWidget {
  // ignore: public_member_api_docs
  const EmptyList({
    @required this.title,
    Key key,
  }) : super(key: key);

  // ignore: public_member_api_docs
  final String title;

  @override
  Widget build(BuildContext context) => Container(
        height: 100,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                Icons.assignment_ind,
                size: 30,
                color: ThemeWidget.of(context).textColorLight,
              ),
              Text(
                title,
                style: TextStyle(
                    color: ThemeWidget.of(context).textColorLight),
              ),
            ],
          ),
        ),
      );
}
