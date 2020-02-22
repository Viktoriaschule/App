import 'package:flutter/material.dart';
import 'package:viktoriaapp/aixformation/aixformation_row.dart';
import 'package:viktoriaapp/app/app_page.dart';
import 'package:viktoriaapp/models/keys.dart';
import 'package:viktoriaapp/utils/pages.dart';
import 'package:viktoriaapp/widgets/custom_app_bar.dart';
import 'package:viktoriaapp/widgets/empty_list.dart';
import 'package:viktoriaapp/widgets/size_limit.dart';
import 'package:viktoriaapp/utils/static.dart';

// ignore: public_member_api_docs
class AiXformationPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Scaffold(
        body: CustomScrollView(
          slivers: [
            CustomAppBar(
              title: Pages.of(context).pages[Keys.aiXformation].title,
              sliver: true,
            ),
            SliverList(
              delegate: SliverChildListDelegate(
                Static.aiXformation.data.posts.isNotEmpty
                    ? Static.aiXformation.data.posts
                        .map((post) => Center(
                              child: SizeLimit(
                                child: Container(
                                  margin: EdgeInsets.all(10),
                                  child: AiXformationRow(
                                    post: post,
                                  ),
                                ),
                              ),
                            ))
                        .toList()
                        .cast<Widget>()
                    : [
                        Center(
                          child: EmptyList(title: 'Keine Artikel'),
                        )
                      ],
              ),
            ),
          ],
        ),
      );
}
