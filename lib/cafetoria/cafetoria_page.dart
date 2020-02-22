import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:viktoriaapp/app/app_page.dart';
import 'package:viktoriaapp/cafetoria/cafetoria_login.dart' as dialog;
import 'package:viktoriaapp/cafetoria/cafetoria_row.dart';
import 'package:viktoriaapp/widgets/custom_app_bar.dart';
import 'package:viktoriaapp/widgets/empty_list.dart';
import 'package:viktoriaapp/widgets/list_group.dart';
import 'package:viktoriaapp/widgets/size_limit.dart';
import 'package:viktoriaapp/utils/static.dart';
import 'package:viktoriaapp/models/models.dart';
import 'package:viktoriaapp/utils/theme.dart';
import 'package:viktoriaapp/utils/pages.dart';

// ignore: public_member_api_docs
class CafetoriaPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => CafetoriaPageState();
}

// ignore: public_member_api_docs
class CafetoriaPageState extends State<CafetoriaPage> {
  @override
  Widget build(BuildContext context) {
    final page = Pages.of(context).pages[Keys.cafetoria];
    final days =
        (Static.cafetoria.data.days..sort((a, b) => a.date.compareTo(b.date)));
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          CustomAppBar(
            title: Static.cafetoria.data.saldo != null
                ? '${page.title} (${Static.cafetoria.data.saldo}€)'
                : page.title,
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
      ),
    );
  }
}
