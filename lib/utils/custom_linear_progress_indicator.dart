import 'package:flutter/material.dart';

// ignore: public_member_api_docs, must_be_immutable
class CustomLinearProgressIndicator extends PreferredSize {
  // ignore: public_member_api_docs
  CustomLinearProgressIndicator({
    Key key,
    Color backgroundColor,
    this.height = 3,
  }) : super(
          key: key,
          child: SizedBox(
            height: height,
            child: LinearProgressIndicator(
              backgroundColor: backgroundColor,
            ),
          ),
          preferredSize: Size.fromHeight(height),
        );

  // ignore: public_member_api_docs
  final double height;

  @override
  Size get preferredSize => Size.fromHeight(height);
}
