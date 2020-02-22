import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:viktoriaapp/app/app_page.dart';
import 'package:viktoriaapp/cafetoria/cafetoria_page.dart';
import 'package:viktoriaapp/cafetoria/cafetoria_row.dart';
import 'package:viktoriaapp/models/models.dart';
import 'package:viktoriaapp/utils/static.dart';
import 'package:viktoriaapp/widgets/custom_bottom_navigation.dart';
import 'package:viktoriaapp/widgets/empty_list.dart';
import 'package:viktoriaapp/utils/info_card.dart';
import 'package:viktoriaapp/widgets/list_group.dart';
import 'package:viktoriaapp/widgets/size_limit.dart';

// ignore: public_member_api_docs
class CafetoriaInfoCard extends StatefulWidget {
  // ignore: public_member_api_docs
  const CafetoriaInfoCard({
    @required this.date,
    @required this.pages,
    @required this.days,
    this.showNavigation = true,
    Key key,
  }) : super(key: key);

  // ignore: public_member_api_docs
  final DateTime date;

  // ignore: public_member_api_docs
  final Map<String, InlinePage> pages;

  // ignore: public_member_api_docs
  final List<CafetoriaDay> days;

  // ignore: public_member_api_docs
  final bool showNavigation;

  @override
  _CafetoriaInfoCardState createState() => _CafetoriaInfoCardState();
}

class _CafetoriaInfoCardState extends State<CafetoriaInfoCard> {
  InfoCardUtils utils;

  @override
  Widget build(BuildContext context) {
    utils ??= InfoCardUtils(context, widget.date);
    final afterDays = widget.days
        .where(
            (d) => d.date.isAfter(widget.date.subtract(Duration(seconds: 1))))
        .toList();
    return ListGroup(
      showNavigation: widget.showNavigation,
      heroId: '${Keys.cafetoria}-0',
      heroIdNavigation: Keys.cafetoria,
      actions: [
        NavigationAction(Icons.list, () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (context) => Scaffold(
                body: CafetoriaPage(page: widget.pages[Keys.cafetoria]),
              ),
            ),
          );
        }),
        NavigationAction(Icons.credit_card, () async {
          await launch('https://www.opc-asp.de/vs-aachen/');
        }),
      ],
      title: Static.cafetoria.data.saldo == null
          ? 'Cafétoria - ${weekdays[widget.date.weekday - 1]}'
          : 'Cafétoria - ${weekdays[widget.date.weekday - 1]} (${Static.cafetoria.data.saldo}€) ',
      counter: widget.days.length - 1,
      children: [
        if (!Static.cafetoria.hasLoadedData ||
            afterDays.isEmpty ||
            afterDays.first.menus.isEmpty)
          EmptyList(title: 'Keine Menüs')
        else
          SizeLimit(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: (afterDays.first.menus.length > utils.cut
                      ? afterDays.first.menus.sublist(0, utils.cut)
                      : afterDays.first.menus)
                  .map(
                    (menu) => Container(
                      margin: EdgeInsets.all(10),
                      child: CafetoriaRow(
                        day: widget.days.first,
                        menu: menu,
                      ),
                    ),
                  )
                  .toList()
                  .cast<Widget>(),
            ),
          ),
      ],
    );
  }
}