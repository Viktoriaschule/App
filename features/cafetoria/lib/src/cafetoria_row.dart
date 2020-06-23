import 'package:cafetoria/cafetoria.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:utils/utils.dart';
import 'package:widgets/widgets.dart';

// ignore: public_member_api_docs
class CafetoriaRow extends PreferredSize {
  // ignore: public_member_api_docs
  const CafetoriaRow({
    @required this.day,
    @required this.menu,
    this.showSplit = true,
  });

  // ignore: public_member_api_docs
  final CafetoriaDay day;

  // ignore: public_member_api_docs
  final CafetoriaMenu menu;

  // ignore: public_member_api_docs
  final bool showSplit;

  @override
  Size get preferredSize => Size.fromHeight(customRowHeight);

  @override
  Widget build(BuildContext context) => CustomRow(
        leading: Icon(
          Icons.restaurant,
          color: ThemeWidget.of(context).textColorLight,
        ),
        title: Text(
          menu.name,
          style: TextStyle(
            fontSize: 17,
            color: Theme.of(context).accentColor,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: menu.price != 0 || menu.time.isNotEmpty
            ? IconsTexts(
                icons: [
                  if (menu.price != 0) MdiIcons.currencyEur,
                  if (menu.time.isNotEmpty) Icons.timer,
                ],
                texts: [
                  if (menu.price != 0)
                    menu.price.toString().replaceAll('.', ','),
                  if (menu.time.isNotEmpty) menu.time,
                ],
              )
            : null,
      );
}
