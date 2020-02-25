import 'dart:io';

import 'command.dart';
import 'generate.dart' as generate;

Future main(List<String> arguments) async {
  var logDebug = false;
  if (arguments.isNotEmpty) {
    logDebug = arguments[0] == '-d' || arguments[0] == '--debug';
  }

  // Check if everything is installed
  final failed = [];
  const programms = ['flutter', 'pub', 'dartfmt', 'dartanalyzer', 'node'];
  for (var i = 0; i < programms.length; i++) {
    final result = await Process.run(programms[i], ['-h'], runInShell: true);
    if (result.exitCode != 0) {
      print('Error: ${programms[i]} is not installed!');
      failed.add(programms[i]);
      if (programms[i] != 'lcov') {
        exit(1);
      }
    }
  }

  print(
      '${programms.length - failed.length}/${programms.length} programms are installed!');

  await runCommand(
    'pub',
    ['global', 'activate', 'test_coverage'],
    log: logDebug,
  );
  await runCommand(
    'flutter',
    ['pub', 'get'],
    log: logDebug,
  );

  await generate.main(arguments);
}
