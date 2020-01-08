import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ginko/cafetoria/cafetoria_row.dart';
import 'package:ginko/utils/static.dart';

//TODO: Add cafetoria login
// ignore: public_member_api_docs
class CafetoriaPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text('Cafétoria'),
        ),
        body: Scrollbar(
          child: ListView(
            shrinkWrap: true,
            children: (Static.cafetoria.data.days
                  ..sort((a, b) => a.date.compareTo(b.date)))
                .map((day) => Column(
                      children: day.menus
                          .map(
                            (menu) => Container(
                              margin: EdgeInsets.all(10),
                              child: CafetoriaRow(
                                day: day,
                                menu: menu,
                                showDate: true,
                              ),
                            ),
                          )
                          .toList()
                          .cast<Widget>(),
                    ))
                .toList()
                .cast<Widget>(),
          ),
        ),
      );
}
