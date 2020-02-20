import 'package:flutter/material.dart';
import 'package:viktoriaapp/aixformation/aixformation_row.dart';
import 'package:viktoriaapp/app/app_page.dart';
import 'package:viktoriaapp/utils/app_bar.dart';
import 'package:viktoriaapp/utils/empty_list.dart';
import 'package:viktoriaapp/utils/size_limit.dart';
import 'package:viktoriaapp/utils/static.dart';

// ignore: public_member_api_docs
class AiXformationPage extends StatelessWidget {
  // ignore: public_member_api_docs
  const AiXformationPage({@required this.page});

  // ignore: public_member_api_docs
  final InlinePage page;

  @override
  Widget build(BuildContext context) => CustomScrollView(
        slivers: [
          CustomAppBar(
            title: page.title,
            actions: page.actions,
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
      );
}
