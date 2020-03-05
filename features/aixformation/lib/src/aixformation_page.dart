import 'package:aixformation/aixformation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_event_bus/flutter_event_bus.dart';
import 'package:widgets/widgets.dart';

import 'aixformation_events.dart';
import 'aixformation_keys.dart';
import 'aixformation_row.dart';

// ignore: public_member_api_docs
class AiXformationPage extends StatefulWidget {
  // ignore: public_member_api_docs
  const AiXformationPage({Key key}) : super(key: key);
  @override
  AiXformationPageState createState() => AiXformationPageState();
}

// ignore: public_member_api_docs
class AiXformationPageState extends Interactor<AiXformationPage> {
  @override
  Widget build(BuildContext context) {
    final loader = AiXFormationWidget.of(context).feature.loader;
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          CustomAppBar(
            title: AiXFormationWidget.of(context).feature.name,
            sliver: true,
            loadingKeys: const [AiXformationKeys.aixformation],
          ),
        ],
        body: CustomRefreshIndicator(
          loadOnline: () => loader.loadOnline(context, force: true),
          child: loader.hasLoadedData && loader.data.posts.isNotEmpty
              ? ListView.builder(
                  padding: EdgeInsets.only(bottom: 10),
                  itemCount: loader.data.posts.length,
                  itemBuilder: (context, index) {
                    final post = loader.data.posts[index];
                    return Center(
                      child: SizeLimit(
                        child: Container(
                          margin: EdgeInsets.all(10),
                          child: AiXformationRow(
                            post: post,
                            posts: loader.data.posts,
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
  }

  @override
  Subscription subscribeEvents(EventBus eventBus) => eventBus
      .respond<AiXformationUpdateEvent>((event) => setState(() => null));
}
