library pwa;

import 'dart:typed_data';

import 'pwa_base.dart';

// ignore: public_member_api_docs
class PWA extends PWABase {
  @override
  Future<bool> install() async => false;

  @override
  bool canInstall() => false;

  @override
  void download(String fileName, Uri uri) {}

  @override
  Future<DummyFile> selectFile() async => DummyFile('', Uint8List(0));
}
