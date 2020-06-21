import 'dart:convert';

import 'package:crypton/crypton.dart';
import 'package:flutter/material.dart';
import 'package:nextcloud/nextcloud.dart';
import 'package:utils/utils.dart';

import '../nextcloud_talk.dart';
import 'nextcloud_talk_events.dart';
import 'nextcloud_talk_keys.dart';
import 'nextcloud_talk_login_dialog.dart';
import 'nextcloud_talk_model.dart';
import 'nextcloud_talk_notification_level_dialog.dart';

/// NextcloudTalkLoader class
class NextcloudTalkLoader extends Loader<NextcloudTalk> {
  // ignore: public_member_api_docs
  NextcloudTalkLoader()
      : super(NextcloudTalkKeys.nextcloudTalk, NextcloudTalkUpdateEvent());

  @override
  // ignore: type_annotate_public_apis, always_declare_return_types
  fromJSON(json) => NextcloudTalk.fromJson(json);

  // ignore: public_member_api_docs
  NextCloudClient get client => NextCloudClient.withCredentials(
        BaseUrl.nextcloud.url,
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

    LoaderResponse<NextcloudTalk> response;
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
                  notificationLevel: c.notificationLevel,
                ))
            .toList()
            .cast<NextcloudTalkChat>(),
      );
      rawData = json.encode(data.toJson());
      save();
      loadedFromOnline = true;
      response = LoaderResponse<NextcloudTalk>(
        data: data,
        statusCode: StatusCode.success,
      );
      // ignore: avoid_catches_without_on_clauses
    } catch (e, stacktrace) {
      print(e);
      if (e is RequestException) {
        print(e.statusCode);
        print(e.body);
      }
      print(stacktrace);
      if (e is RequestException) {
        if (e.statusCode == 401) {
          if (showLoginOnWrongCredentials && context != null) {
            await Navigator.of(context).pushReplacementNamed('/${Keys.login}');
          }
        }
        response = LoaderResponse<NextcloudTalk>(
          statusCode:
              e.statusCode == 401 ? StatusCode.unauthorized : StatusCode.failed,
        );
      } else {
        response = LoaderResponse<NextcloudTalk>(
          statusCode: StatusCode.failed,
        );
      }
    }
    if (Platform().isMobile) {
      if (Static.storage.getString(Keys.rsaPrivateKey) == null) {
        try {
          var client = NextCloudClient.withoutLogin(
            BaseUrl.nextcloud.url,
            appType: appType,
            language: language,
          );
          final init = await client.login.initLoginFlow();
          final result = await showDialog<LoginFlowResult>(
            context: context,
            barrierDismissible: false,
            builder: (context) => NextcloudTalkLoginDialog(
              init: init,
            ),
          );
          if (result != null) {
            client = NextCloudClient.withAppPassword(
              BaseUrl.nextcloud.url,
              result.appPassword,
              appType: appType,
              language: language,
            );
            final token = await Static.firebaseMessaging.getToken();
            final keypair = RSAKeypair.fromRandom(keySize: 2048);
            try {
              await client.notifications.registerDeviceAtServer(
                token,
                keypair,
                proxyServerUrl: 'https://push.2bad2c0.de',
              );
              Static.storage.setString(
                Keys.rsaPrivateKey,
                keypair.privateKey.toFormattedPEM(),
              );
              // ignore: avoid_catches_without_on_clauses
            } catch (e, stacktrace) {
              print(e);
              if (e is RequestException) {
                print(e.statusCode);
                print(e.body);
              }
              print(stacktrace);
            }
          }
          // ignore: avoid_catches_without_on_clauses
        } catch (e, stacktrace) {
          print(e);
          if (e is RequestException) {
            print(e.statusCode);
            print(e.body);
          }
          print(stacktrace);
        }
      }
      if (Static.storage.getString(Keys.rsaPrivateKey) != null) {
        try {
          final loader = NextcloudTalkWidget.of(context).feature.loader;
          final _chats = loader.hasLoadedData
              ? loader.data.chats.toList()
              : <NextcloudTalkChat>[];
          final guiltyChats = _chats
              .where(
                  (chat) => chat.notificationLevel != NotificationLevel.always)
              .toList();
          if (guiltyChats.isNotEmpty) {
            if (!Static.storage.has(
              NextcloudTalkKeys.automaticallyChangeNotificationLevel,
            )) {
              await showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => NextcloudTalkNotificationLevelDialog(
                  chats: guiltyChats,
                ),
              );
            } else if (Static.storage.getBool(
              NextcloudTalkKeys.automaticallyChangeNotificationLevel,
            )) {
              final conversationManagement =
                  loader.client.talk.conversationManagement;
              for (final chat in guiltyChats) {
                await conversationManagement.setNotificationLevel(
                  chat.token,
                  NotificationLevel.always,
                );
              }
            }
          }
          // ignore: avoid_catches_without_on_clauses
        } catch (e, stacktrace) {
          print(e);
          if (e is RequestException) {
            print(e.statusCode);
            print(e.body);
          }
          print(stacktrace);
        }
      }
    }
    sendLoadedEvent(loadingStates, eventBus);
    return response;
  }
}
