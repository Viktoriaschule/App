library firebase;

import 'package:firebase_messaging/firebase_messaging.dart';

/// THIS IMPLEMENTATION ONLY HAS THE FEATURES USED BY THE APP
/// NOT YET IMPLEMENTED FEATURES CAN BE IMPLEMENTED EASILY IF NEEDED

/// Implementation of the Firebase Cloud Messaging API for Flutter.
///
/// Your app should call [requestNotificationPermissions] first and then
/// register handlers for incoming messages with [configure].
abstract class FirebaseMessagingBase {
  /// On iOS and Web, prompts the user for notification permissions the
  /// first time it is called.
  ///
  /// Does nothing on Android.
  Future<bool> requestNotificationPermissions(
      [IosNotificationSettings iosSettings = const IosNotificationSettings()]);

  /// On Web, check if permission is given
  Future<bool> hasNotificationPermissions();

  /// Stream that fires when the user changes their notification settings.
  ///
  /// Only fires on iOS.
  Stream<IosNotificationSettings> get onIosSettingsRegistered;

  /// Sets up [MessageHandler] for incoming messages.
  void configure({
    MessageHandler onMessage,
    MessageHandler onBackgroundMessage,
    MessageHandler onLaunch,
    MessageHandler onResume,
  });

  /// Fires when a new FCM token is generated.
  Stream<String> get onTokenRefresh;

  /// Returns the FCM token.
  Future<String> getToken();
}
