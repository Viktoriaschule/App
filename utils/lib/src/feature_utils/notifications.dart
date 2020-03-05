import 'package:flutter/material.dart';

/// The notifications handler for each feature
abstract class NotificationsHandler {
  /// Returns the text for the in app notification snack bar
  String getSnackBarText(Map<String, dynamic> data, BuildContext context);

  /// The open handler for a notification
  ///
  /// The notification data can be used to open the correct page with the correct parameters
  void open(Map<String, dynamic> data, BuildContext context);
}
