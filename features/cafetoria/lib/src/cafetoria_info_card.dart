import 'package:cafetoria/cafetoria.dart';
import 'package:flutter/material.dart';
import 'package:flutter_event_bus/flutter_event_bus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:utils/utils.dart';
import 'package:widgets/widgets.dart';

import 'cafetoria_keys.dart';
import 'cafetoria_model.dart';
import 'cafetoria_page.dart';
import 'cafetoria_row.dart';

// ignore: public_member_api_docs
class CafetoriaInfoCard extends StatefulWidget {
  // ignore: public_member_api_docs
  const CafetoriaInfoCard({
    @required this.date,
    this.showNavigation = true,
    this.isSingleDay = false,
    Key key,
  }) : super(key: key);

  // ignore: public_member_api_docs
  final DateTime date;

  // ignore: public_member_api_docs
  final bool showNavigation;

  // ignore: public_member_api_docs
  final bool isSingleDay;

  @override
  _CafetoriaInfoCardState createState() => _CafetoriaInfoCardState();
}

class _CafetoriaInfoCardState extends Interactor<CafetoriaInfoCard> {
  InfoCardUtils utils;

  List<CafetoriaDay> getDays(CafetoriaLoader loader) => loader.hasLoadedData
      ? (loader.data.days.toList()..sort((a, b) => a.date.compareTo(b.date)))
          .toList()
      : [];

  @override
  Subscription subscribeEvents(EventBus eventBus) => eventBus
      .respond<CafetoriaUpdateEvent>((event) => update())
      .respond<TagsUpdateEvent>((event) => update());

  void update() {
    setState(() => null);
  }

  @override
  Widget build(BuildContext context) {
    utils ??= InfoCardUtils(context, widget.date);
    final loader = CafetoriaWidget.of(context).feature.loader;
    final _days = getDays(loader);
    final afterDays = _days
        .where(
            (d) => d.date.isAfter(widget.date.subtract(Duration(seconds: 1))))
        .toList();
    return ListGroup(
      loadingKeys: [CafetoriaKeys.cafetoria],
      showNavigation: widget.showNavigation,
      heroId: '${CafetoriaKeys.cafetoria}-0',
      heroIdNavigation: CafetoriaKeys.cafetoria,
      actions: [
        NavigationAction(Icons.list, () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (context) => CafetoriaPage(),
            ),
          );
        }),
        NavigationAction(Icons.credit_card, () async {
          await launch('https://www.opc-asp.de/vs-aachen/');
        }),
      ],
      title: !loader.hasLoadedData || loader.data.saldo == null
          ? 'Cafétoria - ${weekdays[widget.date.weekday - 1]}'
          : 'Cafétoria - ${weekdays[widget.date.weekday - 1]} (${loader.data.saldo}€) ',
      counter: _days.length - 1,
      children: [
        if (!loader.hasLoadedData ||
            afterDays.isEmpty ||
            afterDays.first.menus.isEmpty)
          EmptyList(title: 'Keine Menüs')
        else
          SizeLimit(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: (afterDays.first.menus.length > utils.cut &&
                          !widget.isSingleDay
                      ? afterDays.first.menus.sublist(0, utils.cut)
                      : afterDays.first.menus)
                  .map(
                    (menu) => Container(
                      margin: EdgeInsets.all(10),
                      child: CafetoriaRow(
                        day: _days.first,
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
