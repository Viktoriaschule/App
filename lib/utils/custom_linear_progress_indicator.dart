import 'package:flutter/material.dart';

// ignore: public_member_api_docs, must_be_immutable
class CustomLinearProgressIndicator extends PreferredSize {
  // ignore: public_member_api_docs
  CustomLinearProgressIndicator({
    Key key,
    Color backgroundColor,
  }) : super(
          key: key,
          child: SizedBox(
            height: 3,
            child: LinearProgressIndicator(
              backgroundColor: backgroundColor,
            ),
          ),
          preferredSize: Size.fromHeight(3),
        );

  @override
  Size get preferredSize => Size.fromHeight(3);
}
