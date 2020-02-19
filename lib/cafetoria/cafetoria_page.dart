import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:viktoriaapp/app/app_page.dart';
import 'package:viktoriaapp/cafetoria/cafetoria_row.dart';
import 'package:viktoriaapp/plugins/platform/platform.dart';
import 'package:viktoriaapp/utils/app_bar.dart';
import 'package:viktoriaapp/utils/bottom_navigation.dart';
import 'package:viktoriaapp/utils/list_group.dart';
import 'package:viktoriaapp/utils/size_limit.dart';
import 'package:viktoriaapp/utils/static.dart';
import 'package:viktoriaapp/models/models.dart';

// ignore: public_member_api_docs
class CafetoriaPage extends StatelessWidget {
  // ignore: public_member_api_docs
  const CafetoriaPage({@required this.page});

  // ignore: public_member_api_docs
  final InlinePage page;

  @override
  Widget build(BuildContext context) {
    final days =
        (Static.cafetoria.data.days..sort((a, b) => a.date.compareTo(b.date)));
    return Column(
      children: <Widget>[
        Expanded(
          child: CustomScrollView(
            slivers: [
              CustomAppBar(
                title: page.title,
                actions: page.actions,
                sliver: true,
              ),
              SliverList(
                delegate: SliverChildListDelegate(
                  days
                      .map((day) => SizeLimit(
                            child: ListGroup(
                              heroId: '${Keys.cafetoria}-${days.indexOf(day)}',
                              title:
                                  // ignore: lines_longer_than_80_chars
                                  '${weekdays[day.date.weekday - 1]} ${shortOutputDateFormat.format(day.date)}',
                              children: day.menus
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
                                  .cast<Widget>(),
                            ),
                          ))
                      .toList()
                      .cast<Widget>(),
                ),
              ),
            ],
          ),
        ),
        Hero(
          tag: !Platform().isWeb ? Keys.navigation(Keys.cafetoria) : this,
          child: Material(
            type: MaterialType.transparency,
            child: BottomNavigation(
              actions: [
                NavigationAction(Icons.expand_less, () {
                  Navigator.pop(context);
                }),
                NavigationAction(Icons.credit_card, () {
                  //TODO: Open cafetoria website
                })
              ],
            ),
          ),
        )
      ],
    );
  }
}
