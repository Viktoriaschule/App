import 'package:aixformation/aixformation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_event_bus/flutter_event_bus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:utils/utils.dart';
import 'package:widgets/widgets.dart';

/// The maximum count for aixformation articles on this page
const maxArticleCount = 100;

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
    final loader = AiXformationWidget.of(context).feature.loader;
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          CustomAppBar(
            title: AiXformationLocalizations.name,
            sliver: true,
            loadingKeys: const [AiXformationKeys.aixformation],
            actions: [
              IconButton(
                icon: Icon(
                  Icons.open_in_new,
                  color: ThemeWidget.of(context).textColor,
                ),
                onPressed: () => launch('https://aixformation.de'),
              ),
            ],
          ),
        ],
        body: CustomRefreshIndicator(
          loadOnline: () => loader.loadOnline(context, force: true),
          child: loader.hasLoadedData && loader.data.posts.isNotEmpty
              ? Scrollbar(
                  child: ListView.builder(
                    padding: EdgeInsets.only(bottom: 10),
                    itemCount: loader.data.posts.length < maxArticleCount
                        ? loader.data.posts.length
                        : maxArticleCount + 1,
                    itemBuilder: (context, index) {
                      final post = loader.data.posts[index];
                      if (index < maxArticleCount) {
                        return Center(
                          child: SizeLimit(
                            child: AiXformationRow(
                              post: post,
                              posts: loader.data.posts,
                            ),
                          ),
                        );
                      }
                      return Padding(
                        padding: EdgeInsets.only(
                            bottom: 10, left: 10, right: 10, top: 20),
                        child: InkWell(
                            onTap: () => launch('https://aixformation.de'),
                            child: Padding(
                              padding: EdgeInsets.all(5),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(AiXformationLocalizations.moreArticles),
                                  Padding(
                                    padding: EdgeInsets.all(5),
                                    child: Icon(
                                      Icons.open_in_new,
                                      color: ThemeWidget.of(context).textColor,
                                    ),
                                  ),
                                ],
                              ),
                            )),
                      );
                    },
                  ),
                )
              : Center(
                  child: EmptyList(title: AiXformationLocalizations.noArticle),
                ),
        ),
      ),
    );
  }

  @override
  Subscription subscribeEvents(EventBus eventBus) => eventBus
      .respond<AiXformationUpdateEvent>((event) => setState(() => null));
}
