import 'package:flutter/material.dart';
import 'package:nextcloud/nextcloud.dart';
import 'package:nextcloud_talk/src/nextcloud_talk_keys.dart';
import 'package:utils/utils.dart';

// ignore: public_member_api_docs
class NextcloudTalk {
  // ignore: public_member_api_docs
  NextcloudTalk({
    @required this.chats,
  }) {
    chats.sort((a, b) {
      if ((a.unreadMessages > 0 && b.unreadMessages > 0) ||
          (a.unreadMessages == 0 && b.unreadMessages == 0)) {
        return b.lastActivity.millisecondsSinceEpoch
            .compareTo(a.lastActivity.millisecondsSinceEpoch);
      } else {
        return a.unreadMessages > 0 ? -1 : 1;
      }
    });
  }

  // ignore: public_member_api_docs
  factory NextcloudTalk.fromJson(Map<String, dynamic> json) => NextcloudTalk(
        chats: json['chats']
            .map((e) => NextcloudTalkChat.fromJson(e))
            .toList()
            .cast<NextcloudTalkChat>(),
      );

  // ignore: public_member_api_docs
  Map<String, dynamic> toJson() => {
        'chats': chats.map((c) => c.toJson()).toList(),
      };

  // ignore: public_member_api_docs
  final List<NextcloudTalkChat> chats;
}

// ignore: public_member_api_docs
class NextcloudTalkChat {
  // ignore: public_member_api_docs
  NextcloudTalkChat({
    @required this.name,
    @required this.displayName,
    @required this.type,
    @required this.unreadMessages,
    @required this.lastActivity,
    @required this.lastPing,
    @required this.lastMessage,
    @required this.token,
  });

  // ignore: public_member_api_docs
  factory NextcloudTalkChat.fromJson(Map<String, dynamic> json) =>
      NextcloudTalkChat(
        name: json['name'],
        displayName: json['displayName'],
        type: ConversationType.values[json['type']],
        unreadMessages: json['unreadMessages'],
        lastActivity: DateTime.parse(json['lastActivity']).toLocal(),
        lastPing: DateTime.parse(json['lastPing']).toLocal(),
        lastMessage: NextcloudTalkMessage.fromJson(json['lastMessage']),
        token: json['token'],
      );

  // ignore: public_member_api_docs
  Map<String, dynamic> toJson() => {
        'name': name,
        'displayName': displayName,
        'type': type.index,
        'unreadMessages': unreadMessages,
        'lastActivity': lastActivity.toIso8601String(),
        'lastPing': lastPing.toIso8601String(),
        'lastMessage': lastMessage.toJson(),
        'token': token,
      };

  /// Load the message from cache
  List<NextcloudTalkMessage> loadOfflineMessages() {
    final data =
        Static.storage.getJSON('${NextcloudTalkKeys.nextcloudTalk}-$token');
    if (data == null) {
      return null;
    }
    return data
        .cast<Map<String, dynamic>>()
        .map((m) => NextcloudTalkMessage.fromJson(m))
        .toList()
        .cast<NextcloudTalkMessage>()
        .toList();
  }

  /// Load the messages from the server
  Future<List<NextcloudTalkMessage>> loadOnlineMessages(
    MessageManagement messageManagement,
  ) async {
    final messages = (await messageManagement.getMessages(token))
        .map((m) => NextcloudTalkMessage.fromPackage(m))
        .toList()
        .reversed
        .toList();
    Static.storage.setJSON('${NextcloudTalkKeys.nextcloudTalk}-$token',
        messages.map((m) => m.toJson()).toList());
    return messages;
  }

  // ignore: public_member_api_docs
  final String name;

  // ignore: public_member_api_docs
  final String displayName;

  // ignore: public_member_api_docs
  final ConversationType type;

  // ignore: public_member_api_docs
  final int unreadMessages;

  // ignore: public_member_api_docs
  final DateTime lastActivity;

  // ignore: public_member_api_docs
  final DateTime lastPing;

  // ignore: public_member_api_docs
  final NextcloudTalkMessage lastMessage;

  // ignore: public_member_api_docs
  final String token;
}

// ignore: public_member_api_docs
class NextcloudTalkMessage {
  // ignore: public_member_api_docs
  NextcloudTalkMessage({
    @required this.message,
    @required this.actorDisplayName,
    @required this.actorId,
    @required this.id,
    @required this.timestamp,
    @required this.messageParameters,
  });

  // ignore: public_member_api_docs
  factory NextcloudTalkMessage.fromJson(Map<String, dynamic> json) =>
      NextcloudTalkMessage(
        message: json['message'],
        actorDisplayName: json['actorDisplayName'],
        actorId: json['actorId'],
        id: json['id'],
        timestamp: DateTime.parse(json['timestamp']).toLocal(),
        messageParameters: json['messageParameters'],
      );

  // ignore: public_member_api_docs
  factory NextcloudTalkMessage.fromPackage(Message message) =>
      NextcloudTalkMessage(
        message: message.message,
        actorDisplayName: message.actorDisplayName,
        actorId: message.actorId,
        id: message.id,
        timestamp: message.timestamp,
        messageParameters:
            message.messageParameters is Map ? message.messageParameters : {},
      );

  // ignore: public_member_api_docs
  Map<String, dynamic> toJson() => {
        'message': message,
        'actorDisplayName': actorDisplayName,
        'actorId': actorId,
        'id': id,
        'timestamp': timestamp.toIso8601String(),
        'messageParameters': messageParameters,
      };

  // ignore: public_member_api_docs
  final String message;

  // ignore: public_member_api_docs
  final String actorDisplayName;

  // ignore: public_member_api_docs
  final String actorId;

  // ignore: public_member_api_docs
  final int id;

  // ignore: public_member_api_docs
  final DateTime timestamp;

  // ignore: public_member_api_docs
  final Map<String, dynamic> messageParameters;
}
