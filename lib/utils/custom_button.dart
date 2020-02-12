import 'package:flutter/material.dart';

// ignore: public_member_api_docs
class CustomButton extends StatelessWidget {
  // ignore: public_member_api_docs
  const CustomButton({
    @required this.onPressed,
    this.focusNode,
    this.margin,
    this.child,
    Key key,
  }) : super(key: key);

  // ignore: public_member_api_docs
  final VoidCallback onPressed;

  // ignore: public_member_api_docs
  final FocusNode focusNode;

  // ignore: public_member_api_docs
  final EdgeInsets margin;

  // ignore: public_member_api_docs
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
        margin: margin,
        child: RaisedButton(
          focusNode: focusNode,
          onPressed: onPressed,
          color: Theme.of(context).accentColor,
          child: child,
        ),
      );
}
