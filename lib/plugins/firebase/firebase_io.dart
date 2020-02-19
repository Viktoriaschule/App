library firebase;

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_messaging/firebase_messaging.dart' as real;
import 'package:viktoriaapp/plugins/firebase/firebase_base.dart';

/// FirebaseMessaging class
/// Firebase messaging for Android and iOS
class FirebaseMessaging extends FirebaseMessagingBase {
  // ignore: public_member_api_docs
  final real.FirebaseMessaging firebaseMessaging = real.FirebaseMessaging();

  @override
  Future<bool> requestNotificationPermissions(
      [IosNotificationSettings iosSettings = const IosNotificationSettings()]) {
    firebaseMessaging.requestNotificationPermissions();
    return Future.value(true);
  }

  @override
  Future<bool> hasNotificationPermissions() async => true;

  @override
  Stream<IosNotificationSettings> get onIosSettingsRegistered =>
      firebaseMessaging.onIosSettingsRegistered;

  @override
  @override
  void configure(
          {MessageHandler onMessage,
          MessageHandler onLaunch,
          MessageHandler onResume}) =>
      firebaseMessaging.configure(
        onMessage: onMessage,
        onLaunch: onLaunch,
        onResume: onResume,
      );

  @override
  Future<String> getToken() => firebaseMessaging.getToken();

  @override
  Stream<String> get onTokenRefresh => firebaseMessaging.onTokenRefresh;
}
