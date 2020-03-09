import 'dart:io';

import 'package:process_run/cmd_run.dart';

Future main(List<String> arguments) async {
  final excludes = <String>[];
  if (arguments.contains('--exclude')) {
    final pos = arguments.indexOf('--exclude');
    for (int i = pos + 1; i < arguments.length; i++) {
      if (arguments[i].startsWith('-')) {
        break;
      }
      excludes.add(arguments[i]);
    }
  }

  final result = (await run(
    'git',
    ['branch'],
    verbose: false,
  ))
      .stdout;
  final branches = result
      .split('\n')
      .map((i) => i.trim())
      .where((i) =>
          i.length > 0 &&
          !i.contains('*') &&
          !i.contains('+') &&
          i != 'master' &&
          !excludes.contains(i))
      .toList();

  if (branches.isNotEmpty) {
    stdout.write(
        'Do you want to delete the banches:\n${branches.join('\n')}\n\n[y|n]:');
    if (stdin.readLineSync().toLowerCase() == 'y') {
      for (final branch in branches) {
        print('Delete branch $branch:');
        await run(
          'git',
          ['branch', '-d', branch],
          verbose: false,
        );
      }
    }
  }

  await run(
    'git',
    ['remote', 'prune', 'origin'],
    verbose: true,
  );
}
