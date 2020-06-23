// Describes a list of calendar events...
import 'package:flutter/material.dart';

import 'ipad_list_localizations.dart';

/// All ipad device types
enum DeviceType {
  /// An ipad
  student,

  /// A lpad
  teacher
}

/// The attribute to sort the devices
enum SortMethod {
  // ignore: public_member_api_docs
  name,
  // ignore: public_member_api_docs
  deviceType,
  // ignore: public_member_api_docs
  batteryLevel,
  // ignore: public_member_api_docs
  isCharging,
  // ignore: public_member_api_docs
  groupID,
}

const _displayNames = [
  IPadListLocalizations.iPadName,
  IPadListLocalizations.iPadType,
  IPadListLocalizations.iPadBatteryLevel,
  IPadListLocalizations.iPadIsCharging,
  IPadListLocalizations.iPadGroup,
  IPadListLocalizations.iPadGroupIndex,
];

const _groupedMethods = [
  SortMethod.groupID,
  SortMethod.isCharging,
  SortMethod.deviceType,
];

/// Adds a to string method
extension SortMethodExtension on SortMethod {
  /// Returns the display name of one of the sort method values
  String get displayName => _displayNames[index];

  /// Whether the sort method is grouped or not
  bool get isGrouped => _groupedMethods.contains(this);
}

/// All loaded data for the ipad list
class IPadList {
  // ignore: public_member_api_docs
  IPadList({this.devices, this.historyEntries});

  /// The devices overview
  Devices devices;

  /// The loading history
  Map<String, List<HistoryEntry>> historyEntries;
}

/// All school devices in the management system
class Devices {
  // ignore: public_member_api_docs
  Devices({@required this.iPads});

  /// Creates the calendar from json map
  factory Devices.fromJson(Map<String, dynamic> json) => Devices(
      iPads: json['devices'].map<IPad>((json) => IPad.fromJson(json)).toList());

  /// All loaded devices
  final List<IPad> iPads;

  /// Sorts the devices with the given method and returns it
  List<IPad> getSortedList(SortMethod sortMethod) =>
      iPads..sort((d1, d2) => d1.compareTo(sortMethod, d2));

  /// Returns the devices grouped by the groupId
  List<List<IPad>> getGroupedList(SortMethod sortMethod) {
    final sorted = getSortedList(sortMethod);
    final grouped = <String, List<IPad>>{};

    for (final iPad in sorted) {
      final key = iPad.getGroupIndex(sortMethod);
      if (!grouped.containsKey(key)) {
        grouped[key] = [];
      }
      grouped[key].add(iPad);
    }

    return grouped.keys.map((key) => grouped[key]).toList();
  }
}

/// One school device
class IPad {
  // ignore: public_member_api_docs
  IPad(
      {this.id,
      this.name,
      this.loggedInUser,
      this.deviceType,
      this.batteryLevel,
      this.isCharging,
      this.groupID,
      this.groupIndex,
      this.lastModified,
      this.lastConnection,
      this.status});

  /// Creates calendar event from json map
  factory IPad.fromJson(Map<String, dynamic> json) => IPad(
        id: json['id'],
        name: json['name'],
        loggedInUser: json['loggedin_user'],
        deviceType: DeviceType.values[json['device_type']],
        batteryLevel: json['battery_level'],
        isCharging: json['is_charging'],
        groupID: json['device_group'],
        groupIndex: json['device_group_index'],
        lastModified: DateTime.parse(json['last_modified']).toLocal(),
        lastConnection: DateTime.parse(json['last_connection']).toLocal(),
        status: json['status'],
      );

  /// Compares the device with the given method to another device
  int compareTo(SortMethod sortMethod, IPad device,
      {List<SortMethod> alreadySorted}) {
    int result;
    switch (sortMethod) {
      case SortMethod.name:
        result = name.compareTo(device.name);
        break;
      case SortMethod.isCharging:
        result = device.isCharging.toString().compareTo(isCharging.toString());
        break;
      case SortMethod.batteryLevel:
        result = batteryLevel.compareTo(device.batteryLevel);
        break;
      case SortMethod.deviceType:
        result = deviceType.index.compareTo(device.deviceType.index);
        break;
      case SortMethod.groupID:
        result = groupID.compareTo(device.groupID);
        break;
    }

    // In the case of equals levels, compare with another method
    if (result == 0) {
      SortMethod newMethod;
      switch (sortMethod) {
        case SortMethod.name:
          newMethod = SortMethod.batteryLevel;
          break;
        case SortMethod.batteryLevel:
          newMethod = SortMethod.isCharging;
          break;
        case SortMethod.isCharging:
          newMethod = SortMethod.groupID;
          break;
        case SortMethod.groupID:
          newMethod = SortMethod.name;
          break;
        case SortMethod.deviceType:
          newMethod = SortMethod.batteryLevel;
      }

      alreadySorted ??= [];
      if (newMethod != null && !alreadySorted.contains(newMethod)) {
        result = compareTo(
          newMethod,
          device,
          alreadySorted: alreadySorted..add(sortMethod),
        );
      }
    }
    return result;
  }

  /// Returns the value to index the groups
  String getGroupIndex(SortMethod sortMethod) {
    switch (sortMethod) {
      case SortMethod.groupID:
        return groupID.toString();
      case SortMethod.isCharging:
        return isCharging.toString();
      case SortMethod.deviceType:
        return deviceType.index.toString();
      default:
        return null;
    }
  }

  /// The device identifier
  final String id;

  /// The device name: The name with the sticker on the iPads
  ///
  /// For example: ipad-03g or ldap-04g for a teacher
  ///
  /// The last letter is the index in the group and the number the group
  final String name;

  /// The name of the currently logged in user
  final String loggedInUser;

  /// If the ipad is from a student or not
  final DeviceType deviceType;

  /// The battery level from 0% to 100%
  final int batteryLevel;

  /// Whether the device is currently charging or not
  final bool isCharging;

  /// The group identifier
  final int groupID;

  /// The group index
  final String groupIndex;

  /// When the device was last modified in the relution system
  final DateTime lastModified;

  /// The last user connection on the device
  final DateTime lastConnection;

  /// The current device status
  final String status;
}

/// The loaded battery history
class DeviceHistory {
  // ignore: public_member_api_docs
  DeviceHistory({this.entries});

  // ignore: public_member_api_docs
  factory DeviceHistory.fromJson(Map<String, dynamic> json) =>
      DeviceHistory(
        entries: json['devices'].map<String, List<HistoryEntry>>(
              (key, entries) =>
              MapEntry<String, List<HistoryEntry>>(
                key,
                entries
                    .map<HistoryEntry>((json) => HistoryEntry.fromJson(json))
                    .toList(),
              ),
        ),
      );

  /// The loading history
  Map<String, List<HistoryEntry>> entries;

  /// Returns the json parsable map
  Map<String, dynamic> toMap() =>
      {
        'devices': entries.map((key, value) =>
            MapEntry(key, value.map((e) => e.toMap()).toList())),
      };
}

/// A history entry of one device to a specif time
class HistoryEntry {
  // ignore: public_member_api_docs
  HistoryEntry({
    this.id,
    this.level,
    this.lastModified,
    this.loggedInUser,
    this.status,
    this.timestamp,
  });

  // ignore: public_member_api_docs
  factory HistoryEntry.fromJson(Map<String, dynamic> json) =>
      HistoryEntry(
        id: json['id'],
        level: json['level'],
        loggedInUser: json['loggedin_user'],
        status: json['status'],
        lastModified: DateTime.parse(json['modified']).toLocal(),
        timestamp: DateTime.parse(json['timestamp']).toLocal(),
      );

  /// The device id
  final String id;

  /// The battery level in percent (0 to 100)
  final int level;

  /// The last device modification of this history entry
  final DateTime lastModified;

  /// The logged in user to this entry time
  final String loggedInUser;

  /// The current status to the time of the entry
  final String status;

  /// The timestamp of synchronizing the battery level to the server
  final DateTime timestamp;

  /// Returns the json parsable map
  Map<String, dynamic> toMap() =>
      {
        'id': id,
        'level': level,
        'loggedin_user': loggedInUser,
        'status': status,
        'modified': lastModified.toIso8601String(),
        'timestamp': timestamp.toIso8601String(),
      };
}
