import 'package:flutter/material.dart';

// ignore: public_member_api_docs
class SizeLimit extends StatelessWidget {
  // ignore: public_member_api_docs
  const SizeLimit({
    @required this.child,
    Key key,
  }) : super(key: key);

  // ignore: public_member_api_docs
  final Widget child;

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: 700,
            ),
            child: child,
          ),
        ],
      );
}
