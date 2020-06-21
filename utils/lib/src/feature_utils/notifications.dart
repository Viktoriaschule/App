import 'package:flutter/material.dart';

/// The notifications handler for each feature
abstract class NotificationsHandler {
  /// Returns the text for the in app notification snack bar
  String getSnackBarText(
    Map<String, dynamic> data,
    BuildContext context,
  );

  /// The open handler for a notification
  ///
  /// The notification data can be used to open the correct page with the correct parameters
  void open(
    Map<String, dynamic> data,
    BuildContext context,
  );

  /// The android notification channel for this feature notifications
  AndroidNotificationChannel getAndroidNotificationHandler(
    BuildContext context,
  );
}

/// The android notification channel
class AndroidNotificationChannel {
  // ignore: public_member_api_docs
  AndroidNotificationChannel(this.key, this.title, this.description);

  /// The feature key
  final String key;

  /// The german human readable channel title
  final String title;

  /// The german human readable channel description for the android settings
  final String description;

  /// Converts the android notification channel to a android code readable map
  Map<String, String> toMap() => {
        'name': key,
        'title': title,
        'description': description,
      };
}
