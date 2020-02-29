import 'package:flutter/material.dart';
import 'package:flutter_event_bus/flutter_event_bus.dart';
import 'package:utils/utils.dart';
import 'package:widgets/widgets.dart';

import 'aixformation_row.dart';

// ignore: public_member_api_docs
class AiXformationPage extends StatefulWidget {
  @override
  AiXformationPageState createState() => AiXformationPageState();
}

// ignore: public_member_api_docs
class AiXformationPageState extends Interactor<AiXformationPage> {
  @override
  Widget build(BuildContext context) => Scaffold(
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            CustomAppBar(
              title: Pages.of(context).pages[Keys.aiXformation].title,
              sliver: true,
              loadingKeys: [Keys.aiXformation],
            ),
          ],
          body: CustomRefreshIndicator(
            loadOnline: () =>
                Static.aiXformation.loadOnline(context, force: true),
            child: Static.aiXformation.hasLoadedData &&
                    Static.aiXformation.data.posts.isNotEmpty
                ? ListView.builder(
                    padding: EdgeInsets.only(bottom: 10),
                    itemCount: Static.aiXformation.data.posts.length,
                    itemBuilder: (context, index) {
                      final post = Static.aiXformation.data.posts[index];
                      return Center(
                        child: SizeLimit(
                          child: Container(
                            margin: EdgeInsets.all(10),
                            child: AiXformationRow(
                              post: post,
                              posts: Static.aiXformation.data.posts,
                            ),
                          ),
                        ),
                      );
                    },
                  )
                : Center(
                    child: EmptyList(title: 'Keine Artikel'),
                  ),
          ),
        ),
      );

  @override
  Subscription subscribeEvents(EventBus eventBus) => eventBus
      .respond<AiXformationUpdateEvent>((event) => setState(() => null));
}
