library storage;

import 'dart:convert';
import 'dart:html';

import 'storage_base.dart';

/// Storage class
/// handles storage on web devices
class Storage extends StorageBase {
  @override
  // ignore: missing_return
  Future init() {}

  @override
  int getInt(String key) => window.localStorage.containsKey(key)
      ? int.tryParse(window.localStorage[key])
      : null;

  @override
  void setInt(String key, int value) => window.localStorage[key] = '$value';

  @override
  String getString(String key) =>
      window.localStorage.containsKey(key) ? window.localStorage[key] : null;

  @override
  void setString(String key, String value) =>
      window.localStorage[key] = '$value';

  @override
  bool getBool(String key) => window.localStorage.containsKey(key)
      ? window.localStorage[key] == 'true'
      : null;

  @override
  void setBool(String key, bool value) => window.localStorage[key] = '$value';

  @override
  List<String> getKeys() => window.localStorage.keys;

  @override
  dynamic getJSON(String key) => json.decode(getString(key));

  @override
  // ignore: type_annotate_public_apis
  void setJSON(String key, value) => setString(key, json.encode(value));

  @override
  void remove(String key) => window.localStorage.remove(key);

  @override
  bool has(String key) => window.localStorage[key] != null;
}
