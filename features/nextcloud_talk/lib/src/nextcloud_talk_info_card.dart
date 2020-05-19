import 'package:flutter/material.dart';
import 'package:nextcloud_talk/nextcloud_talk.dart';
import 'package:nextcloud_talk/src/nextcloud_talk_localizations.dart';
import 'package:nextcloud_talk/src/nextcloud_talk_model.dart';
import 'package:nextcloud_talk/src/nextcloud_talk_page.dart';
import 'package:utils/utils.dart';
import 'package:widgets/widgets.dart';

import 'nextcloud_talk_events.dart';
import 'nextcloud_talk_keys.dart';
import 'nextcloud_talk_row.dart';

// ignore: public_member_api_docs
class NextcloudTalkInfoCard extends InfoCard {
  // ignore: public_member_api_docs
  const NextcloudTalkInfoCard({
    @required DateTime date,
    double maxHeight,
  }) : super(
          date: date,
          maxHeight: maxHeight,
        );

  @override
  _NextcloudTalkInfoCardState createState() => _NextcloudTalkInfoCardState();
}

class _NextcloudTalkInfoCardState extends InfoCardState<NextcloudTalkInfoCard> {
  InfoCardUtils utils;

  @override
  Subscription subscribeEvents(EventBus eventBus) => eventBus
      .respond<NextcloudTalkUpdateEvent>((event) => setState(() => null));

  @override
  ListGroup build(BuildContext context) {
    final loader = NextcloudTalkWidget.of(context).feature.loader;
    final _chats = loader.hasLoadedData
        ? loader.data.chats.where((c) => c.unreadMessages > 0).toList()
        : <NextcloudTalkChat>[];
    final cut = InfoCardUtils.cut(
      getScreenSize(MediaQuery.of(context).size.width),
      _chats.length,
    );
    return ListGroup(
      loadingKeys: const [NextcloudTalkKeys.nextcloudTalk],
      heroId: NextcloudTalkKeys.nextcloudTalk,
      title: NextcloudTalkLocalizations.name,
      counter: _chats.length - cut,
      maxHeight: widget.maxHeight,
      actions: [
        NavigationAction(Icons.expand_more, () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (context) => NextcloudTalkPage(),
            ),
          );
        }),
      ],
      children: [
        if (_chats.isEmpty)
          EmptyList(title: NextcloudTalkLocalizations.noUnreadMessages)
        else
          ...(_chats.length > cut ? _chats.sublist(0, cut) : _chats)
              .map((chat) => NextcloudTalkRow(chat: chat))
              .toList()
              .cast<PreferredSize>(),
      ],
    );
  }
}
