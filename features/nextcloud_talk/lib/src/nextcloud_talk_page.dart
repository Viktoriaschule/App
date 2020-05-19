import 'package:flutter/material.dart';
import 'package:flutter_event_bus/flutter_event_bus.dart';
import 'package:nextcloud/nextcloud.dart';
import 'package:nextcloud_talk/nextcloud_talk.dart';
import 'package:nextcloud_talk/src/nextcloud_talk_create_chat_dialog.dart';
import 'package:nextcloud_talk/src/nextcloud_talk_row.dart';
import 'package:utils/utils.dart';
import 'package:widgets/widgets.dart';

import 'nextcloud_talk_chat_page.dart';
import 'nextcloud_talk_events.dart';
import 'nextcloud_talk_keys.dart';
import 'nextcloud_talk_localizations.dart';
import 'nextcloud_talk_model.dart';

// ignore: public_member_api_docs
class NextcloudTalkPage extends StatefulWidget {
  // ignore: public_member_api_docs
  const NextcloudTalkPage({Key key}) : super(key: key);

  @override
  _NextcloudTalkPageState createState() => _NextcloudTalkPageState();
}

class _NextcloudTalkPageState extends Interactor<NextcloudTalkPage>
    with TickerProviderStateMixin {
  List<NextcloudTalkChat> chats;

  @override
  Subscription subscribeEvents(EventBus eventBus) => eventBus
      .respond<NextcloudTalkUpdateEvent>((event) => setState(() => null));

  @override
  Widget build(BuildContext context) {
    final loader = NextcloudTalkWidget.of(context).feature.loader;
    final _chats = loader.hasLoadedData
        ? loader.data.chats.toList()
        : <NextcloudTalkChat>[];
    return Scaffold(
      appBar: CustomAppBar(
        title: NextcloudTalkLocalizations.name,
        loadingKeys: const [NextcloudTalkKeys.nextcloudTalk],
        actions: [
          IconButton(
            icon: Icon(Icons.group_add),
            onPressed: () async {
              final args = await showDialog(
                context: context,
                builder: (context) => NextcloudTalkCreateChatDialog(),
              );
              if (args != null && args.isNotEmpty) {
                final bool groupChat = args[0];
                final String name = args[1];
                final List<String> users = args[2];
                final talk =
                    NextcloudTalkWidget.of(context).feature.loader.client.talk;
                NextcloudTalkWidget.of(context)
                    .feature
                    .loader
                    .sendLoadingEvent(LoadingState.of(context), eventBus);
                if (groupChat) {
                  final token =
                      await talk.conversationManagement.createConversation(
                    ConversationType.group,
                    name: name,
                  );
                  for (final user in users) {
                    await talk.conversationManagement
                        .addParticipant(token, user);
                  }
                } else {
                  await talk.conversationManagement.createConversation(
                    ConversationType.oneToOne,
                    invite: users.first,
                  );
                }
                await NextcloudTalkWidget.of(context)
                    .feature
                    .loader
                    .loadOnline(context, force: true);
              }
            },
          )
        ],
      ),
      body: loader.hasLoadedData
          ? CustomRefreshIndicator(
              loadOnline: () => loader.loadOnline(context, force: true),
              child: Scrollbar(
                child: ListView.builder(
                  padding: EdgeInsets.all(10),
                  itemCount: _chats.length,
                  itemBuilder: (context, index) => SizeLimit(
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (context) => NextcloudTalkChatPage(
                              chat: _chats[index],
                            ),
                          ),
                        );
                      },
                      child: NextcloudTalkRow(
                        chat: _chats[index],
                      ),
                    ),
                  ),
                ),
              ),
            )
          : EmptyList(title: NextcloudTalkLocalizations.noUnreadMessages),
    );
  }
}
