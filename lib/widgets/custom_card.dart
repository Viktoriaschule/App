import 'package:flutter/material.dart';

// ignore: public_member_api_docs
class CustomCard extends StatefulWidget {
  // ignore: public_member_api_docs
  const CustomCard(
      {@required this.child, Key key, this.margin, this.color, this.elevation})
      : super(key: key);

  // ignore: public_member_api_docs
  final EdgeInsets margin;

  // ignore: public_member_api_docs
  final Color color;

  // ignore: public_member_api_docs
  final double elevation;

  // ignore: public_member_api_docs
  final Widget child;

  @override
  _CustomCardState createState() => _CustomCardState();
}

class _CustomCardState extends State<CustomCard>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    final CardTheme cardTheme = CardTheme.of(context);

    return Semantics(
      container: true,
      child: Container(
        margin: widget.margin ?? cardTheme.margin ?? const EdgeInsets.all(4),
        child: AnimatedSize(
          vsync: this,
          curve: Curves.fastOutSlowIn,
          duration: Duration(milliseconds: 200),
          child: Material(
            type: MaterialType.card,
            color:
                widget.color ?? cardTheme.color ?? Theme.of(context).cardColor,
            elevation: widget.elevation ?? cardTheme.elevation ?? 1,
            shape: cardTheme.shape ??
                const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                ),
            clipBehavior: cardTheme.clipBehavior ?? Clip.none,
            child: Semantics(
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}
