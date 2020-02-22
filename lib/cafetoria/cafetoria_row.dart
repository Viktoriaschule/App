import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:viktoriaapp/models/models.dart';
import 'package:viktoriaapp/widgets/custom_row.dart';
import 'package:viktoriaapp/widgets/icons_texts.dart';
import 'package:viktoriaapp/utils/theme.dart';

// ignore: public_member_api_docs
class CafetoriaRow extends StatefulWidget {
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
  State<StatefulWidget> createState() => _CafetoriaRowState();
}

class _CafetoriaRowState extends State<CafetoriaRow> {
  @override
  Widget build(BuildContext context) => CustomRow(
        leading: Icon(
          Icons.restaurant,
          color: textColorLight(context),
        ),
        title: widget.menu.name,
        subtitle: IconsTexts(
          icons: [
            if (widget.menu.price != 0) MdiIcons.currencyEur,
            if (widget.menu.time.isNotEmpty) Icons.timer,
          ],
          texts: [
            if (widget.menu.price != 0)
              widget.menu.price.toString().replaceAll('.', ','),
            if (widget.menu.time.isNotEmpty) widget.menu.time,
          ],
        ),
      );
}
