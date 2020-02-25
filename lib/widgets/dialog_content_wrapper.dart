import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:viktoriaapp/widgets/size_limit.dart';

/// DialogContentWrapper class
/// wrap the content of a dialog
class DialogContentWrapper extends StatelessWidget {
  // ignore: public_member_api_docs
  const DialogContentWrapper({
    @required this.children,
    this.spread = false,
    Key key,
  }) : super(key: key);

  // ignore: public_member_api_docs
  final List<Widget> children;

  // ignore: public_member_api_docs
  final bool spread;

  @override
  Widget build(BuildContext context) => SizeLimit(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.75,
              height: spread
                  ? MediaQuery.of(context).size.height * 0.75 - 22
                  : null,
              child: Container(
                padding: EdgeInsets.only(
                  left: 12.5,
                  right: 12.5,
                  bottom: 7.5,
                ),
                child: Column(
                  mainAxisAlignment: spread
                      ? MainAxisAlignment.spaceBetween
                      : MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: children
                      .map((child) => Container(
                            width: double.infinity,
                            margin: spread &&
                                    children.indexOf(child) ==
                                        children.length - 1
                                ? EdgeInsets.only(top: 20)
                                : null,
                            child: child,
                          ))
                      .toList()
                      .cast<Widget>(),
                ),
              ),
            ),
          ],
        ),
      );
}
