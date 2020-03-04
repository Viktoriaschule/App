import 'dart:io';

import 'package:process_run/cmd_run.dart';
import 'package:scripts/base_dir.dart';

Future main(List<String> arguments) async {
  await checkDir(baseDir);
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
        await run(
          'flutter',
          [
            'pub',
            'get',
          ],
          workingDirectory: dir.path,
          verbose: true,
        );
      } else {
        await checkDir(dir.path);
      }
    }
  }
}
