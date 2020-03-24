import 'package:flutter/material.dart';

// ignore: public_member_api_docs
class CustomButton extends StatelessWidget {
  // ignore: public_member_api_docs
  const CustomButton({
    @required this.onPressed,
    @required this.child,
    this.focusNode,
    this.margin,
    this.enabled = true,
    Key key,
  }) : super(key: key);

  // ignore: public_member_api_docs
  final VoidCallback onPressed;

  // ignore: public_member_api_docs
  final FocusNode focusNode;

  // ignore: public_member_api_docs
  final EdgeInsets margin;

  // ignore: public_member_api_docs
  final bool enabled;

  // ignore: public_member_api_docs
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
        margin: margin,
        child: RaisedButton(
          focusNode: focusNode,
          onPressed: enabled ? onPressed : null,
          color: Theme.of(context).accentColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(4)),
          ),
          child: child,
        ),
      );
}
