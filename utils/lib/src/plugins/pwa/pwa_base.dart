library pwa;

import 'dart:typed_data';

// ignore: public_member_api_docs
abstract class PWABase {
  // ignore: public_member_api_docs
  Future<bool> install();

  // ignore: public_member_api_docs
  bool canInstall();

  // ignore: public_member_api_docs
  void download(String fileName, Uri uri);

  // ignore: public_member_api_docs
  Future<DummyFile> selectFile();
}

// ignore: public_member_api_docs
class DummyFile {
  // ignore: public_member_api_docs
  const DummyFile(this.name, this.content);

  // ignore: public_member_api_docs
  final String name;

  // ignore: public_member_api_docs
  final Uint8List content;
}
