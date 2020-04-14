import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// The fix height of a custom row
///
/// Included with the [customRowVerticalMargin]
const double customRowHeight = 60;

/// The fix custom rom vertical margin
const double customRowVerticalMargin = 20;

// ignore: public_member_api_docs
class CustomRow extends PreferredSize {
  // ignore: public_member_api_docs
  const CustomRow({
    @required this.leading,
    @required this.title,
    this.subtitle,
    this.last,
    this.titleColor,
    this.titleFontWeight,
    this.titleAlignment,
    this.titleOverflow,
    this.splitColor,
    this.showSplit,
    this.heroTag,
    this.hasMargin = true,
  });

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
  final TextOverflow titleOverflow;

  // ignore: public_member_api_docs
  final Color splitColor;

  // ignore: public_member_api_docs
  final bool showSplit;

  // ignore: public_member_api_docs
  final dynamic heroTag;

  /// The margin of this row, default all 10
  final bool hasMargin;

  @override
  Size get preferredSize => Size.fromHeight(customRowHeight);

  @override
  Widget build(BuildContext context) => Container(
        height: customRowHeight - 20,
        margin: hasMargin ? EdgeInsets.all(customRowVerticalMargin / 2) : null,
        child: Row(
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
                height: customRowHeight - 26,
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
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (title != null)
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: titleFontWeight,
                        color: titleColor ?? Theme.of(context).accentColor,
                      ),
                      overflow: titleOverflow ?? TextOverflow.ellipsis,
                    ),
                  if (subtitle != null) subtitle,
                ],
              ),
            ),
            if (last != null) last,
          ],
        ),
      );
}
