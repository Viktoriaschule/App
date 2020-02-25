import 'package:flutter/material.dart';
import 'package:flutter_event_bus/flutter_event_bus/EventBus.dart';
import 'package:flutter_event_bus/flutter_event_bus/Interactor.dart';
import 'package:flutter_event_bus/flutter_event_bus/Subscription.dart';
import 'package:viktoriaapp/aixformation/aixformation_row.dart';
import 'package:viktoriaapp/models/keys.dart';
import 'package:viktoriaapp/utils/events.dart';
import 'package:viktoriaapp/utils/pages.dart';
import 'package:viktoriaapp/utils/static.dart';
import 'package:viktoriaapp/widgets/custom_app_bar.dart';
import 'package:viktoriaapp/widgets/custom_refresh_indicator.dart';
import 'package:viktoriaapp/widgets/empty_list.dart';
import 'package:viktoriaapp/widgets/size_limit.dart';

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
            child: Static.aiXformation.data.posts.isNotEmpty
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
