import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

// ignore: public_member_api_docs
class CustomRow extends StatelessWidget {
  // ignore: public_member_api_docs
  const CustomRow({
    @required this.leading,
    @required this.title,
    this.subtitle,
    this.last,
    this.titleColor,
    this.titleFontWeight,
    this.titleAlignment,
    this.splitColor,
    this.showSplit,
    Key key,
  }) : super(key: key);

  // ignore: public_member_api_docs
  final Widget leading;

  // ignore: public_member_api_docs
  final String title;

  // ignore: public_member_api_docs
  final Widget subtitle;

  // ignore: public_member_api_docs
  final Widget last;

  // ignore: public_member_api_docs
  final Color titleColor;

  // ignore: public_member_api_docs
  final FontWeight titleFontWeight;

  // ignore: public_member_api_docs
  final CrossAxisAlignment titleAlignment;

  // ignore: public_member_api_docs
  final Color splitColor;

  // ignore: public_member_api_docs
  final bool showSplit;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          if (leading != null)
            Container(
              width: 30,
              child: Center(
                child: leading,
              ),
            ),
          if (showSplit ?? true)
            Container(
              height: 40,
              width: 2.5,
              margin: EdgeInsets.only(
                right: 5,
              ),
              color: splitColor ?? Colors.transparent,
            ),
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: titleAlignment ?? CrossAxisAlignment.start,
              children: [
                if (title != null)
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: titleFontWeight,
                      color: titleColor ?? Theme.of(context).accentColor,
                    ),
                   overflow: TextOverflow.ellipsis,
                   maxLines: 1,
                  ),
                if (subtitle != null) subtitle,
              ],
            ),
          ),
          if (last != null) last,
        ],
      );
}
