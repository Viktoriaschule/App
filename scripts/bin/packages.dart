import 'dart:io';

import 'package:scripts/command.dart';

Future main(List<String> arguments) async {
  await checkDir('.');
}

Future checkDir(String path) async {
  final elements = Directory(path).listSync();
  for (final element in elements) {
    final dir = Directory(element.path);
    final pubspec = File('${element.path}/pubspec.yaml');
    final pathFragments = dir.path.split(RegExp('/|\\\\'));
    if (dir.existsSync() &&
        !pathFragments[pathFragments.length - 1].startsWith('.')) {
      if (pubspec.existsSync()) {
        print('Run flutter pub get in ${dir.path}');
        await runCommand('flutter', ['pub', 'get'], log: true, dir: dir.path);
      } else {
        await checkDir(dir.path);
      }
    }
  }
}
