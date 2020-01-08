import 'dart:convert';
import 'dart:io';

Future<dynamic> runCommand(String cmd,
    {List<String> attributes, String dir, bool log, bool runInShell}) async {
  print('Run: $cmd ($dir)');
  if (dir != null) {
    final currentDir = Directory.current.toString().split('\'')[1];
    dir = '$currentDir/$dir';
  }

  final process = await Process.start(cmd, attributes ?? [],
      runInShell: runInShell ?? true, workingDirectory: dir);

  var out = '';

  await process.stdout.transform(utf8.decoder).listen((data) {
    if (data.isNotEmpty) {
      if (log ?? false) {
        print(data.trim());
      }
      out += data;
    }
  }).asFuture();

  final exitCode = await process.exitCode;

  if (exitCode != 0) {
    print('Error: Failed to run \'$cmd\' in $dir!');
    print(out);

    return {
      'stdout': out,
      'exitCode': exitCode,
    };
  }

  return {
    'stdout': out,
    'exitCode': exitCode,
  };
}
