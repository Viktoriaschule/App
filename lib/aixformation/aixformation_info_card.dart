import 'package:flutter/material.dart';
import 'package:flutter_event_bus/flutter_event_bus.dart';
import 'package:viktoriaapp/aixformation/aixformation_page.dart';
import 'package:viktoriaapp/aixformation/aixformation_row.dart';
import 'package:viktoriaapp/models/models.dart';
import 'package:viktoriaapp/utils/events.dart';
import 'package:viktoriaapp/utils/info_card.dart';
import 'package:viktoriaapp/utils/static.dart';
import 'package:viktoriaapp/widgets/custom_bottom_navigation.dart';
import 'package:viktoriaapp/widgets/empty_list.dart';
import 'package:viktoriaapp/widgets/list_group.dart';

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
    utils ??= InfoCardUtils(context, widget.date);
    final List<Post> posts = Static.aiXformation.hasLoadedData
        ? Static.aiXformation.data.posts.length > utils.cut
            ? Static.aiXformation.data.posts.sublist(0, utils.cut)
            : Static.aiXformation.data.posts
        : [];
    return ListGroup(
      loadingKeys: [Keys.aiXformation],
      heroId: Keys.aiXformation,
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
      counter: Static.aiXformation.hasLoadedData
          ? Static.aiXformation.data.posts.length - utils.cut
          : 0,
      children: [
        if (Static.aiXformation.hasLoadedData &&
            Static.aiXformation.data.posts.isNotEmpty)
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
