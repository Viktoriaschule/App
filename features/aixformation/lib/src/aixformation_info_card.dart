import 'package:aixformation/aixformation.dart';
import 'package:aixformation/src/aixformation_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_event_bus/flutter_event_bus.dart';
import 'package:utils/utils.dart';
import 'package:widgets/widgets.dart';

import 'aixformation_events.dart';
import 'aixformation_keys.dart';
import 'aixformation_page.dart';
import 'aixformation_row.dart';

// ignore: public_member_api_docs
class AiXformationInfoCard extends InfoCard {
  // ignore: public_member_api_docs
  const AiXformationInfoCard({
    @required DateTime date,
    double maxHeight,
  }) : super(
          date: date,
          maxHeight: maxHeight,
        );

  @override
  _AiXformationInfoCardState createState() => _AiXformationInfoCardState();
}

class _AiXformationInfoCardState extends InfoCardState<AiXformationInfoCard> {
  @override
  Subscription subscribeEvents(EventBus eventBus) => eventBus
      .respond<AiXformationUpdateEvent>((event) => setState(() => null));

  @override
  ListGroup build(BuildContext context) {
    final loader = AiXformationWidget.of(context).feature.loader;
    final cut = InfoCardUtils.cut(
      getScreenSize(MediaQuery.of(context).size.width),
      loader.hasLoadedData ? loader.data.posts.length : 0,
    );
    return ListGroup(
      loadingKeys: const [AiXformationKeys.aixformation],
      heroId: AiXformationKeys.aixformation,
      doRowsHandleClick: true,
      actions: [
        NavigationAction(Icons.expand_more, () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (context) => AiXformationPage(),
            ),
          );
        }),
      ],
      title: AiXformationLocalizations.name,
      counter: loader.hasLoadedData ? loader.data.posts.length - cut : 0,
      maxHeight: widget.maxHeight,
      children: [
        if (loader.hasLoadedData && loader.data.posts.isNotEmpty)
          ...(loader.data.posts.length > cut
                  ? loader.data.posts.sublist(0, cut)
                  : loader.data.posts)
              .map((post) => AiXformationRow(
                    post: post,
                    posts: loader.data.posts,
                  ))
              .toList()
              .cast<Widget>()
        else
          EmptyList(title: AiXformationLocalizations.noArticle)
      ],
    );
  }
}
