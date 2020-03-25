import 'package:cafetoria/cafetoria.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_event_bus/flutter_event_bus.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:utils/utils.dart';
import 'package:widgets/widgets.dart';

// ignore: public_member_api_docs
class CafetoriaPage extends StatefulWidget {
  // ignore: public_member_api_docs
  const CafetoriaPage({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => CafetoriaPageState();
}

// ignore: public_member_api_docs
class CafetoriaPageState extends Interactor<CafetoriaPage> {
  @override
  Subscription subscribeEvents(EventBus eventBus) => eventBus
      .respond<CafetoriaUpdateEvent>((event) => setState(() => null))
      .respond<TagsUpdateEvent>((event) => setState(() => null));

  @override
  Widget build(BuildContext context) {
    final name = CafetoriaLocalizations.name;
    final loader = CafetoriaWidget.of(context).feature.loader;
    final days = (loader.data.days..sort((a, b) => a.date.compareTo(b.date)));
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          CustomAppBar(
            title: loader.data.saldo != null
                ? '$name (${loader.data.saldo}€)'
                : name,
            loadingKeys: [CafetoriaKeys.cafetoria, Keys.tags],
            actions: [
              IconButton(
                onPressed: () async {
                  const url = 'https://www.opc-asp.de/vs-aachen/';
                  if (await canLaunch(url)) {
                    await launch(url);
                  }
                },
                icon: Icon(
                  Icons.open_in_new,
                  color: ThemeWidget.of(context).textColor,
                ),
              ),
              IconButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    child: CafetoriaLoginDialog(
                      onFinished: () => setState(() => null),
                    ),
                  );
                },
                icon: Icon(
                  MdiIcons.account,
                  color: ThemeWidget.of(context).textColor,
                ),
              ),
            ],
            sliver: true,
          ),
        ],
        body: CustomRefreshIndicator(
          loadOnline: () async => reduceStatusCodes([
            await Static.tags.syncToServer(
              context,
              [CafetoriaWidget.of(context).feature],
            ),
            await loader.loadOnline(context, force: true),
          ]),
          child: days.isNotEmpty
              ? Scrollbar(
                  child: ListView.builder(
                    padding: EdgeInsets.only(bottom: 10),
                    itemCount: days.length,
                    itemBuilder: (context, index) {
                      final day = days[index];
                      return SizeLimit(
                        child: ListGroup(
                          heroId:
                              '${CafetoriaKeys.cafetoria}-${days.indexOf(day)}',
                          title:
                              // ignore: lines_longer_than_80_chars
                              '${weekdays[day.date.weekday - 1]} ${shortOutputDateFormat.format(day.date)}',
                          children: day.menus.isNotEmpty
                              ? day.menus
                                  .map(
                                    (menu) => CafetoriaRow(
                                      day: day,
                                      menu: menu,
                                    ),
                                  )
                                  .toList()
                                  .cast<PreferredSize>()
                              : [
                                  EmptyList(
                                      title: CafetoriaLocalizations.noMenus)
                                ],
                        ),
                      );
                    },
                  ),
                )
              : Center(
                  child: EmptyList(title: CafetoriaLocalizations.noMenus),
                ),
        ),
      ),
    );
  }
}
