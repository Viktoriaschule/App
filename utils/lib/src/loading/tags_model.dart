import 'package:flutter/material.dart';

/// All tags of the current user
class Tags {
  // ignore: public_member_api_docs
  Tags({
    this.userType,
    this.group,
    this.data,
  });

  /// Creates the tags model from json map
  factory Tags.fromJson(Map<String, dynamic> json) {
    if (json.keys.isEmpty) {
      return Tags();
    }
    return Tags(
      group: json['group'],
      userType: json['userType'],
      data: json,
    );
  }

  /// The user grade
  final String group;

  /// The user group (pupil/developer/teacher)
  final int userType;

  /// The raw tags
  final Map<String, dynamic> data;

  /// Checks if the user is already initialized in the server
  bool get isInitialized => group != null;
}

/// Describes a device
class Device {
  // ignore: public_member_api_docs
  Device({
    @required this.os,
    @required this.appVersion,
    @required this.deviceSettings,
    @required this.firebaseId,
    @required this.package,
  });

  // ignore: public_member_api_docs
  final String os;

  // ignore: public_member_api_docs
  final String appVersion;

  // ignore: public_member_api_docs
  final Map<String, bool> deviceSettings;

  // ignore: public_member_api_docs
  final String firebaseId;

  // ignore: public_member_api_docs
  final String package;

  /// Convert a device to a json map
  Map<String, dynamic> toMap() => {
        'os': os,
        'appVersion': appVersion,
        'firebaseId': firebaseId,
        'package': package,
        'settings': deviceSettings,
      };
}
