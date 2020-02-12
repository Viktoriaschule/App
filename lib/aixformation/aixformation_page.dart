import 'package:flutter/material.dart';
import 'package:ginko/aixformation/aixformation_row.dart';
import 'package:ginko/app/app_page.dart';
import 'package:ginko/models/models.dart';
import 'package:ginko/plugins/platform/platform.dart';
import 'package:ginko/utils/app_bar.dart';
import 'package:ginko/utils/bottom_navigation.dart';
import 'package:ginko/utils/empty_list.dart';
import 'package:ginko/utils/size_limit.dart';
import 'package:ginko/utils/static.dart';
import 'package:ginko/utils/theme.dart';

// ignore: public_member_api_docs
class AiXformationPage extends StatelessWidget {
  // ignore: public_member_api_docs
  const AiXformationPage({@required this.page});

  // ignore: public_member_api_docs
  final InlinePage page;

  @override
  Widget build(BuildContext context) => Column(
        children: <Widget>[
          Expanded(
            child: Hero(
              tag: !Platform().isWeb ? Keys.aiXformation : hashCode,
              child: Material(
                type: MaterialType.transparency,
                child: CustomScrollView(
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
                ),
              ),
            ),
          ),
          Hero(
            tag: !Platform().isWeb ? Keys.navigation(Keys.aiXformation) : this,
            child: Material(
              type: MaterialType.transparency,
              child: BottomNavigation(
                actions: [
                  NavigationAction(Icons.expand_less, () {
                    Navigator.pop(context);
                  }),
                ],
              ),
            ),
          ),
        ],
      );
}
