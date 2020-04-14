import 'package:cafetoria/cafetoria.dart';
import 'package:flutter/material.dart';
import 'package:flutter_event_bus/flutter_event_bus.dart';
import 'package:utils/utils.dart';
import 'package:widgets/widgets.dart';

// ignore: public_member_api_docs
class CafetoriaInfoCard extends InfoCard {
  // ignore: public_member_api_docs
  const CafetoriaInfoCard({
    @required DateTime date,
    double maxHeight,
    this.isSingleDay = false,
    this.showNavigation = true,
  }) : super(
          date: date,
          maxHeight: maxHeight,
        );

  // ignore: public_member_api_docs
  final bool showNavigation;

  /// If this card is only for a single day
  final bool isSingleDay;

  @override
  _CafetoriaInfoCardState createState() => _CafetoriaInfoCardState();
}

class _CafetoriaInfoCardState extends InfoCardState<CafetoriaInfoCard> {
  InfoCardUtils utils;

  List<CafetoriaDay> getDays(CafetoriaLoader loader) => loader.hasLoadedData
      ? (loader.data.days.toList()..sort((a, b) => a.date.compareTo(b.date)))
          .toList()
      : [];

  @override
  Subscription subscribeEvents(EventBus eventBus) => eventBus
      .respond<CafetoriaUpdateEvent>((event) => setState(() => null))
      .respond<TagsUpdateEvent>((event) => setState(() => null));

  @override
  ListGroup build(BuildContext context) {
    final loader = CafetoriaWidget.of(context).feature.loader;
    final _days = getDays(loader);
    final afterDays = _days
        .where(
            (d) => d.date.isAfter(widget.date.subtract(Duration(seconds: 1))))
        .toList();
    final cut = InfoCardUtils.cut(
      getScreenSize(MediaQuery.of(context).size.width),
      afterDays.isNotEmpty ? afterDays.first.menus.length : 0,
    );
    return ListGroup(
      loadingKeys: const [CafetoriaKeys.cafetoria],
      showNavigation: widget.showNavigation,
      heroId: '${CafetoriaKeys.cafetoria}-0',
      heroIdNavigation: CafetoriaKeys.cafetoria,
      actions: [
        NavigationAction(Icons.expand_more, () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (context) => CafetoriaPage(),
            ),
          );
        }),
      ],
      title: !loader.hasLoadedData ||
              loader.data.saldo == null ||
              widget.isSingleDay
          ? '${CafetoriaWidget.of(context).feature.name} - ${weekdays[widget.date.weekday - 1]}'
          : '${CafetoriaWidget.of(context).feature.name} - ${weekdays[widget.date.weekday - 1]} (${loader.data.saldo}€) ',
      counter: _days.length - 1,
      maxHeight: widget.maxHeight,
      children: [
        if (!loader.hasLoadedData ||
            afterDays.isEmpty ||
            afterDays.first.menus.isEmpty)
          EmptyList(title: 'Keine Menüs')
        else
          ...(afterDays.first.menus.length > cut && !widget.isSingleDay
                  ? afterDays.first.menus.sublist(0, cut)
                  : afterDays.first.menus)
              .map(
                (menu) => CafetoriaRow(
                  day: afterDays.first,
                  menu: menu,
                ),
              )
              .toList()
              .cast<PreferredSize>(),
      ],
    );
  }
}
