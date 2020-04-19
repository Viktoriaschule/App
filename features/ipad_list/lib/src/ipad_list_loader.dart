import 'package:flutter/material.dart';
import 'package:ipad_list/src/ipad_list_events.dart';
import 'package:ipad_list/src/ipad_list_keys.dart';
import 'package:ipad_list/src/ipad_list_model.dart';
import 'package:utils/utils.dart';

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
  StatusCode loadOffline(BuildContext context) => reduceStatusCodes([
        batteryHistoryLoader.loadOffline(context),
        super.loadOffline(context),
      ]);

  /// The loader to manage the battery history data
  final _BatteryHistoryLoader batteryHistoryLoader = _BatteryHistoryLoader();
}

/// The battery history loader
///
/// This loads always the data for the given ids, but caches all requests, so
/// each loaded id have to be only loaded once and also can be used offline
class _BatteryHistoryLoader extends Loader<BatteryHistory> {
  // ignore: public_member_api_docs
  _BatteryHistoryLoader()
      : super(
          IPadListKeys.iPadBatteryEntries,
          IPadListUpdateEvent(),
        );

  @override
  bool get alwaysPost => true;

  @override
  BaseUrl get baseUrl => BaseUrl.viktoriaManagement;

  @override
  BatteryHistory get data => _batteryHistory;

  final BatteryHistory _batteryHistory = BatteryHistory();

  @override
  // ignore: type_annotate_public_apis, always_declare_return_types
  fromJSON(json) => BatteryHistory.fromJson(json);

  @override
  StatusCode loadOffline(BuildContext context) {
    final status = super.loadOffline(context);
    // Save the parsed data in an extra attribute, because after each load online call,
    // the parsed data will be override by the new data
    _batteryHistory.entries = parsedData?.entries ?? {};
    return status;
  }

  @override
  void save() {
    // Get old ids
    final oldData = Static.storage.getJSON(key);

    // Add the loaded entries to the old entries
    if (oldData != null) {
      parsedData.entries.forEach((key, value) {
        _batteryHistory.entries[key] = value;
      });
    }

    Static.storage.setJSON(key, _batteryHistory.toMap());
  }

  /// Returns the battery history for the given devices
  Future<BatteryHistory> getBatteryHistory(
      BuildContext context, List<IPad> devices,
      {bool forceReload = false}) async {
    List<String> ids = devices.map((d) => d.id).toList();

    if (!forceReload) {
      ids =
          ids.where((id) => !_batteryHistory.entries.containsKey(id)).toList();
    }

    if (ids.isNotEmpty) {
      await loadOnline(
        context,
        force: true,
        body: {'ids': ids},
      );
    }

    final history = BatteryHistory(entries: {});
    for (final device in devices) {
      history.entries[device.id] = _batteryHistory.entries[device.id] ?? [];
    }
    return history;
  }
}
