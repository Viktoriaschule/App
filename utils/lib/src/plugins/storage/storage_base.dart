library storage;

/// StorageBase class
/// describes the abstract layer of storage
abstract class StorageBase {
  // ignore: public_member_api_docs
  Future init();

  // ignore: public_member_api_docs
  void setInt(String key, int value);

  // ignore: public_member_api_docs
  int getInt(String key);

  // ignore: public_member_api_docs
  void setString(String key, String value);

  // ignore: public_member_api_docs
  String getString(String key);

  // ignore: public_member_api_docs
  void setBool(String key, bool value);

  // ignore: public_member_api_docs
  bool getBool(String key);

  // ignore: public_member_api_docs, type_annotate_public_apis
  void setJSON(String key, value);

  // ignore: public_member_api_docs
  dynamic getJSON(String key);

  // ignore: public_member_api_docs
  List<String> getKeys();

  // ignore: public_member_api_docs
  void remove(String key);

  // ignore: public_member_api_docs
  bool has(String key);
}
