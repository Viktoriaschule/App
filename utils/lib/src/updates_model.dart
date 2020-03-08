/// Defines all updates
class Updates {
  // ignore: public_member_api_docs
  Updates({Map<String, String> rawUpdate}) {
    _rawUpdates = rawUpdate;
  }

  /// Creates updates from json map
  factory Updates.fromJson(Map<String, dynamic> json) {
    final updates = <String, String>{};
    json.keys
        .where((element) => element != 'minAppLevel')
        .forEach((element) => updates[element] = json[element]);
    return Updates(rawUpdate: updates);
  }

  @override
  String toString() => _rawUpdates.toString();

  Map<String, String> _rawUpdates;

  // ignore: public_member_api_docs
  String getUpdate(String key) => _rawUpdates[key] ?? '';

  // ignore: public_member_api_docs
  void setUpdate(String key, String hash) => _rawUpdates[key] = hash;
}
