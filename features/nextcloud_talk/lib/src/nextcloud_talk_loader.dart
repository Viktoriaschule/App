import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:nextcloud/nextcloud.dart';
import 'package:utils/utils.dart';

import 'nextcloud_talk_events.dart';
import 'nextcloud_talk_keys.dart';
import 'nextcloud_talk_model.dart';

/// NextcloudTalkLoader class
class NextcloudTalkLoader extends Loader<NextcloudTalk> {
  // ignore: public_member_api_docs
  NextcloudTalkLoader()
      : super(NextcloudTalkKeys.nextcloudTalk, NextcloudTalkUpdateEvent());

  @override
  // ignore: type_annotate_public_apis, always_declare_return_types
  fromJSON(json) => NextcloudTalk.fromJson(json);

  // ignore: public_member_api_docs
  NextCloudClient get client => NextCloudClient(
        'nc.vs-ac.de',
        Static.user.username,
        Static.user.password,
      );

  @override
  bool get forceUpdate => true;

  @override
  Future<LoaderResponse<NextcloudTalk>> load(
    BuildContext context, {
    String username,
    String password,
    bool force = false,
    bool post = false,
    Map<String, dynamic> body,
    bool store = true,
    bool showLoginOnWrongCredentials = true,
  }) async {
    if (loadedFromOnline && !force) {
      return LoaderResponse(statusCode: StatusCode.success);
    }

    final loadingStates = context != null ? LoadingState.of(context) : null;
    final eventBus = context != null ? EventBus.of(context) : null;

    // Inform the gui about this loading process
    sendLoadingEvent(loadingStates, eventBus);

    try {
      final conversations =
          await client.talk.conversationManagement.getUserConversations();
      data = NextcloudTalk(
        chats: conversations
            .map((c) => NextcloudTalkChat(
                  name: c.name,
                  displayName: c.displayName,
                  type: c.type,
                  unreadMessages: c.unreadMessages,
                  lastActivity: c.lastActivity,
                  lastMessage: NextcloudTalkMessage.fromPackage(c.lastMessage),
                  token: c.token,
                  lastPing: c.lastPing,
                ))
            .toList()
            .cast<NextcloudTalkChat>(),
      );
      rawData = json.encode(data.toJson());
      save();
      loadedFromOnline = true;
      sendLoadedEvent(loadingStates, eventBus);
      return LoaderResponse<NextcloudTalk>(
        data: data,
        statusCode: StatusCode.success,
      );
    } on RequestException catch (e, stacktrace) {
      print(e);
      print(stacktrace);
      sendLoadedEvent(loadingStates, eventBus);
      if (e.statusCode == 401) {
        if (showLoginOnWrongCredentials && context != null) {
          await Navigator.of(context).pushReplacementNamed('/${Keys.login}');
        }
      }
      return LoaderResponse<NextcloudTalk>(
        statusCode:
            e.statusCode == 401 ? StatusCode.unauthorized : StatusCode.failed,
      );
    }
  }
}
