@JS('window')
library pwa;

import 'dart:async';
import 'dart:html';
import 'dart:js';
import 'dart:typed_data';

import 'package:viktoriaapp/plugins/pwa/pwa_base.dart';
import 'package:js/js.dart';

// ignore: avoid_annotating_with_dynamic
typedef Callback = void Function(dynamic result);

// ignore: public_member_api_docs
class PWA extends PWABase {
  // ignore: public_member_api_docs
  PWA() {
    _deferredPrompt = context['deferredPrompt'];
  }

  BeforeInstallPromptEvent _deferredPrompt;

  @override
  Future<bool> install() async {
    if (_deferredPrompt != null) {
      await _deferredPrompt.prompt();
      // ignore: omit_local_variable_types
      final Map<String, dynamic> choiceResult =
          await _deferredPrompt.userChoice;
      final accepted = choiceResult['outcome'] == 'accepted';
      if (accepted) {
        _deferredPrompt = null;
      }
      return accepted;
    }
    return false;
  }

  @override
  bool canInstall() => _deferredPrompt != null;

  @override
  void download(String fileName, Uri uri) {
    final link = document.createElement('a')
      ..setAttribute('download', fileName)
      ..setAttribute('href', uri.toString())
      ..setAttribute('target', '_blank');
    document.body.append(link);
    link.click();
  }

  @override
  Future<DummyFile> selectFile() {
    final completer = Completer<DummyFile>();
    final InputElement link = document.createElement('input')
      ..setAttribute('type', 'file');
    link.onChange.listen((e) {
      final files = link.files;
      if (files.isNotEmpty) {
        final file = files[0];
        final reader = FileReader();
        reader.onLoad.listen((e) {
          completer.complete(DummyFile(file.name, reader.result));
        });
        reader.onError.listen((e) {
          print(reader.error.message);
          completer.complete(DummyFile('', Uint8List(0)));
        });
        reader.readAsArrayBuffer(file);
      } else {
        completer.complete(DummyFile('', Uint8List(0)));
      }
    });
    link.click();
    return completer.future;
  }
}
