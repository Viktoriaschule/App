import 'package:aixformation/aixformation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_event_bus/flutter_event_bus.dart';
import 'package:utils/utils.dart';
import 'package:widgets/widgets.dart';

import 'aixformation_keys.dart';
import 'aixformation_model.dart';
import 'aixformation_page.dart';
import 'aixformation_row.dart';

// ignore: public_member_api_docs
class AiXformationInfoCard extends StatefulWidget {
  // ignore: public_member_api_docs
  const AiXformationInfoCard({
    @required this.date,
    Key key,
  }) : super(key: key);

  // ignore: public_member_api_docs
  final DateTime date;

  @override
  _AiXformationInfoCardState createState() => _AiXformationInfoCardState();
}

class _AiXformationInfoCardState extends Interactor<AiXformationInfoCard> {
  InfoCardUtils utils;

  @override
  Widget build(BuildContext context) {
    final loader = AiXFormationWidget.of(context).feature.loader;
    utils ??= InfoCardUtils(context, widget.date);
    final List<Post> posts = loader.hasLoadedData
        ? loader.data.posts.length > utils.cut
            ? loader.data.posts.sublist(0, utils.cut)
            : loader.data.posts
        : [];
    return ListGroup(
      loadingKeys: [AiXformationKeys.aiXformation],
      heroId: AiXformationKeys.aiXformation,
      actions: [
        NavigationAction(Icons.expand_more, () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (context) => AiXformationPage(),
            ),
          );
        }),
      ],
      title: 'AiXformation',
      counter: loader.hasLoadedData ? loader.data.posts.length - utils.cut : 0,
      children: [
        if (loader.hasLoadedData && loader.data.posts.isNotEmpty)
          ...posts
              .map((post) => Container(
                    margin: EdgeInsets.all(10),
                    child: AiXformationRow(
                      post: post,
                      posts: posts,
                    ),
                  ))
              .toList()
              .cast<Widget>()
        else
          EmptyList(title: 'Keine Artikel')
      ],
    );
  }

  @override
  Subscription subscribeEvents(EventBus eventBus) => eventBus
      .respond<AiXformationUpdateEvent>((event) => setState(() => null));
}
