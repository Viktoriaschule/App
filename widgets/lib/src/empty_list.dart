import 'package:flutter/material.dart';
import 'package:utils/utils.dart';

const _height = 100.0;

// ignore: public_member_api_docs
class EmptyList extends PreferredSize {
  // ignore: public_member_api_docs
  const EmptyList({@required this.title});

  // ignore: public_member_api_docs
  final String title;

  @override
  Size get preferredSize => Size.fromHeight(_height);

  @override
  Widget build(BuildContext context) => Container(
        height: _height,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
Icon(
                Icons.assignment_ind,
                size: 30,
                color: ThemeWidget.of(context).textColorLight,
              ),
              Text(
                title,
                style: TextStyle(color: ThemeWidget.of(context).textColorLight),
              ),
            ],
          ),
        ),
      );
}
