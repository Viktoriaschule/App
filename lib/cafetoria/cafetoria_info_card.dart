import 'package:flutter/material.dart';
import 'package:flutter_event_bus/flutter_event_bus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:viktoriaapp/app/app_page.dart';
import 'package:viktoriaapp/cafetoria/cafetoria_page.dart';
import 'package:viktoriaapp/cafetoria/cafetoria_row.dart';
import 'package:viktoriaapp/models/models.dart';
import 'package:viktoriaapp/utils/events.dart';
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

  List<CafetoriaDay> _days;

  List<CafetoriaDay> getDays() => Static.cafetoria.hasLoadedData
      ? (Static.cafetoria.data.days.toList()
            ..sort((a, b) => a.date.compareTo(b.date)))
          .toList()
      : [];

  @override
  void initState() {
    _days = getDays();
    super.initState();
  }

  @override
  Subscription subscribeEvents(EventBus eventBus) =>
      eventBus.respond<CafetoriaUpdateEvent>(
          (event) => setState(() => _days = getDays()));

  @override
  Widget build(BuildContext context) {
    utils ??= InfoCardUtils(context, widget.date);
    final afterDays = _days
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
              builder: (context) => CafetoriaPage(),
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
      counter: _days.length - 1,
      children: [
        if (!Static.cafetoria.hasLoadedData ||
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
