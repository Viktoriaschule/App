import 'package:flutter/material.dart';
import 'package:utils/utils.dart';

import 'ipad_list_events.dart';
import 'ipad_list_keys.dart';
import 'ipad_list_model.dart';

/// IPad list loader class
class IPadListLoader extends Loader<Devices> {
  // ignore: public_member_api_docs
  IPadListLoader() : super(IPadListKeys.iPadList, IPadListUpdateEvent());

  @override
  // ignore: type_annotate_public_apis, always_declare_return_types
  fromJSON(json) => Devices.fromJson(json);

  @override
  BaseUrl get baseUrl => BaseUrl.viktoriaManagement;

  @override
  bool get forceUpdate => true;

  @override
  StatusCode loadOffline(BuildContext context) => reduceStatusCodes([
        deviceHistoryLoader.loadOffline(context),
        super.loadOffline(context),
      ]);

  /// The loader to manage the battery history data
  final _HistoryLoader deviceHistoryLoader = _HistoryLoader();
}

/// The history loader
///
/// This loads always the data for the given ids, but caches all requests, so
/// each loaded id can be used offline and as preview for the next time
class _HistoryLoader extends Loader<DeviceHistory> {
  // ignore: public_member_api_docs
  _HistoryLoader()
      : super(
          IPadListKeys.iPadHistoryEntries,
          IPadListUpdateEvent(),
        );

  @override
  bool get alwaysPost => true;

  @override
  BaseUrl get baseUrl => BaseUrl.viktoriaManagement;

  @override
  DeviceHistory get data => _history;

  final DeviceHistory _history = DeviceHistory();

  @override
  // ignore: type_annotate_public_apis, always_declare_return_types
  fromJSON(json) => DeviceHistory.fromJson(json);

  @override
  StatusCode loadOffline(BuildContext context) {
    final status = super.loadOffline(context);
    // Save the parsed data in an extra attribute, because after each load online call,
    // the parsed data will be override by the new data
    _history.entries = data?.entries ?? {};
    return status;
  }

  @override
  void save() {
    // Get old ids
    final oldData = Static.storage.getJSON(key);

    // Add the loaded entries to the old entries
    if (oldData != null) {
      data.entries.forEach((key, value) {
        _history.entries[key] = value;
      });
    }

    Static.storage.setJSON(key, _history.toMap());
  }

  /// Returns the battery history for the given devices
  Future<DeviceHistory> getDeviceHistory(
      BuildContext context, List<IPad> devices, DateTime date,
      {bool loadOffline = false}) async {
    final ids = devices.map((d) => d.id).toList();

    if (ids.isNotEmpty && !loadOffline) {
      await loadOnline(
        context,
        force: true,
        body: {
          'ids': ids,
          'date': date.toUtc().toIso8601String(),
        },
      );
    }

    final history = DeviceHistory(entries: {});
    for (final device in devices) {
      history.entries[device.id] = _history.entries[device.id]
              ?.where((d) => !d.lastModified.isBefore(date))
              ?.toList() ??
          [];
      history.entries[device.id]
          .sort((d1, d2) => d1.lastModified.compareTo(d2.lastModified));
    }
    return history;
  }
}
