import 'package:flutter/material.dart';

// ignore: public_member_api_docs
class CustomCircularProgressIndicator extends StatelessWidget {
  // ignore: public_member_api_docs
  const CustomCircularProgressIndicator({
    this.height = 30,
    this.width = 30,
    this.color,
    Key key,
  }) : super(key: key);

  // ignore: public_member_api_docs
  final double height;

  // ignore: public_member_api_docs
  final double width;

  // ignore: public_member_api_docs
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        height: height,
        width: width,
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(
              color ?? Theme.of(context).accentColor),
          strokeWidth: 2,
        ),
      );
}
