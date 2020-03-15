@JS('firebase')
library firebase;

import 'dart:async';
import 'dart:convert';
import 'dart:html';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:js/js.dart';
import 'package:js/js_util.dart';

import 'firebase_base.dart';
import 'notification_web.dart';

// ignore: avoid_annotating_with_dynamic
typedef DataCallback = void Function(dynamic data);

// ignore: public_member_api_docs
external Messaging messaging();

@JS()
// ignore: public_member_api_docs
class Messaging {
  // ignore: public_member_api_docs
  external dynamic getToken();

  // ignore: public_member_api_docs
  external void onTokenRefresh(VoidCallback callback);

  // ignore: public_member_api_docs, type_annotate_public_apis
  external void onMessage(DataCallback callback);
}

/// FirebaseMessaging class
/// Firebase messaging for Web
class FirebaseMessaging extends FirebaseMessagingBase {
  Messaging _messaging;
  MessageHandler _onMessage;

  // TODO: figure out what to do with onBackgroundMessage
  // ignore: unused_field
  MessageHandler _onBackgroundMessage;
  MessageHandler _onLaunch;
  MessageHandler _onResume;

  @override
  Future<bool> requestNotificationPermissions(
      [IosNotificationSettings iosSettings =
          const IosNotificationSettings()]) async {
    final permission = await Notification.requestPermission();
    if (permission == 'granted') {
      print('Notification permission granted.');
      return true;
    } else {
      print('Unable to get permission to notify.');
      return false;
    }
  }

  @override
  Future<bool> hasNotificationPermissions() async => permission == 'granted';

  @override
  // ignore: missing_return
  Stream<IosNotificationSettings> get onIosSettingsRegistered {
    // No need to implement, because it's never going to be called
  }

  @override
  void configure({
    MessageHandler onMessage,
    MessageHandler onBackgroundMessage,
    MessageHandler onLaunch,
    MessageHandler onResume,
  }) {
    _onMessage = onMessage;
    _onBackgroundMessage = onBackgroundMessage;
    _onLaunch = onLaunch;
    _onResume = onResume;
    _messaging = messaging();
    window.navigator.serviceWorker.addEventListener('message', (rawEvent) {
      final MessageEvent event = rawEvent;
      final Map<String, dynamic> data = event.data.cast<String, dynamic>();
      if (data['type'] != null) {
        if (data['type'] == '1') {
          _onResume(data['data']);
        } else {
          final messageChannel = MessageChannel();
          window.navigator.serviceWorker.controller
              .postMessage('received', [messageChannel.port2]);
          _onLaunch(data['data']);
        }
      } else {
        _onMessage(json
            .decode(json.encode(data['firebase-messaging-msg-data']['data'])));
      }
    });
  }

  @override
  Future<String> getToken() => promiseToFuture(_messaging.getToken());

  @override
  Stream<String> get onTokenRefresh {
    final controller = StreamController<String>();
    _messaging.onTokenRefresh(
        () async => controller.add(await _messaging.getToken()));
    controller.onCancel = controller.close;
    return controller.stream;
  }
}
