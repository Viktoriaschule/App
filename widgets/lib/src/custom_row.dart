import 'package:flutter/cupertino.dart';
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
    this.splitColor,
    this.showSplit = true,
    this.heroTag,
    this.hasMargin = true,
  });

  /// The widget left of the split
  final Widget leading;

  /// The row title
  final Widget title;

  /// The widget directly below the title
  final Widget subtitle;

  /// The widget on the right end of the row
  final Widget last;

  // ignore: public_member_api_docs
  final Color splitColor;

  /// Whether the vertical split between leading and the rest should be shown
  final bool showSplit;

  // ignore: public_member_api_docs
  final dynamic heroTag;

  /// The margin of this row, default all 10
  final bool hasMargin;

  @override
  Size get preferredSize => Size.fromHeight(customRowHeight);

  @override
  Widget build(BuildContext context) => Container(
        margin: hasMargin ? EdgeInsets.all(customRowVerticalMargin / 2) : null,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
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
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (title != null) title,
                  if (subtitle != null) subtitle,
                ],
              ),
            ),
            if (last != null) last,
          ],
        ),
      );
}
