import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:viktoriaapp/app/app_page.dart';
import 'package:viktoriaapp/cafetoria/cafetoria_login.dart' as dialog;
import 'package:viktoriaapp/cafetoria/cafetoria_row.dart';
import 'package:viktoriaapp/utils/app_bar.dart';
import 'package:viktoriaapp/utils/empty_list.dart';
import 'package:viktoriaapp/utils/list_group.dart';
import 'package:viktoriaapp/utils/size_limit.dart';
import 'package:viktoriaapp/utils/static.dart';
import 'package:viktoriaapp/models/models.dart';
import 'package:viktoriaapp/utils/theme.dart';

// ignore: public_member_api_docs
class CafetoriaPage extends StatefulWidget {
  // ignore: public_member_api_docs
  const CafetoriaPage({@required this.page});

  // ignore: public_member_api_docs
  final InlinePage page;

  @override
  State<StatefulWidget> createState() => CafetoriaPageState();
}

// ignore: public_member_api_docs
class CafetoriaPageState extends State<CafetoriaPage> {
  @override
  Widget build(BuildContext context) {
    final days =
        (Static.cafetoria.data.days..sort((a, b) => a.date.compareTo(b.date)));
    return CustomScrollView(
      slivers: [
        CustomAppBar(
          title: Static.cafetoria.data.saldo != null
              ? '${widget.page.title} (${Static.cafetoria.data.saldo}€)'
              : widget.page.title,
          actions: [
            IconButton(
              onPressed: () async {
                const url = 'https://www.opc-asp.de/vs-aachen/';
                if (await canLaunch(url)) {
                  await launch(url);
                }
              },
              icon: Icon(
                Icons.credit_card,
                size: 28,
                color: textColor(context),
              ),
            ),
            IconButton(
              onPressed: () {
                showDialog(
                  context: context,
                  child: dialog.CafetoriaLogin(
                    onFinished: () => setState(() => null),
                  ),
                );
              },
              icon: Icon(
                MdiIcons.account,
                size: 28,
                color: textColor(context),
              ),
            ),
          ],
          sliver: true,
        ),
        SliverList(
          delegate: SliverChildListDelegate(
            (Static.cafetoria.data.days
                  ..sort((a, b) => a.date.compareTo(b.date)))
                .map((day) => SizeLimit(
                      child: ListGroup(
                        heroId: '${Keys.cafetoria}-${days.indexOf(day)}',
                        title:
                            // ignore: lines_longer_than_80_chars
                            '${weekdays[day.date.weekday - 1]} ${shortOutputDateFormat.format(day.date)}',
                        children: day.menus.isNotEmpty
                            ? day.menus
                                .map(
                                  (menu) => Container(
                                    margin: EdgeInsets.all(10),
                                    child: CafetoriaRow(
                                      day: day,
                                      menu: menu,
                                    ),
                                  ),
                                )
                                .toList()
                                .cast<Widget>()
                            : [EmptyList(title: 'Keine Menüs')],
                      ),
                    ))
                .toList()
                .cast<Widget>(),
          ),
        ),
      ],
    );
  }
}
