import 'package:flutter/material.dart';
import 'package:viktoriaapp/utils/theme.dart';

// ignore: public_member_api_docs
class IconsTexts extends StatelessWidget {
  // ignore: public_member_api_docs
  const IconsTexts({
    @required this.icons,
    @required this.texts,
    this.vertical = false,
    this.space = 15,
    Key key,
  })  : assert(icons.length == texts.length, 'same count of icons as texts'),
        super(key: key);

  // ignore: public_member_api_docs
  final List<IconData> icons;

  // ignore: public_member_api_docs
  final List<String> texts;

  // ignore: public_member_api_docs
  final bool vertical;

  // ignore: public_member_api_docs
  final double space;

  @override
  Widget build(BuildContext context) {
    final items = icons
        .map((icon) {
          final i = icons.indexOf(icon);
          final text = texts[i];
          return Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: ThemeWidget.of(context).textColorLight(),
              ),
              Container(
                width: 2.5,
                height: 1,
                color: Colors.transparent,
              ),
              Text(
                text,
                style: TextStyle(
                    color: ThemeWidget.of(context).textColor(),
                    fontSize: 14,
                    fontWeight: FontWeight.w100),
              ),
              if (i != icons.length - 1)
                Container(
                  width: space,
                  height: 1,
                  color: Colors.transparent,
                ),
            ],
          );
        })
        .toList()
        .cast<Widget>();
    if (vertical) {
      return Column(
        children: items,
      );
    }
    return Row(
      children: items,
    );
  }
}
