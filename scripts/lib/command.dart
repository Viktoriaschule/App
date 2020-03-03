import 'dart:convert';
import 'dart:io';

// ignore: public_member_api_docs
Future<dynamic> runCommand(
  String cmd,
  List<String> attributes, {
  String dir,
  bool log,
  bool runInShell,
}) async {
  if (dir != null) {
    final currentDir = Directory.current.toString().split('\'')[1];
    dir = '$currentDir/$dir';
  }

  final process = await Process.start(cmd, attributes ?? [],
      runInShell: runInShell ?? true, workingDirectory: dir);

  var out = '';
  var err = '';

  await process.stdout.transform(utf8.decoder).listen((data) {
    if (data.isNotEmpty) {
      if (log ?? false) {
        print(data.trim());
      }
      out += data;
    }
  }).asFuture();
  await process.stderr.transform(utf8.decoder).listen((data) {
    if (data.isNotEmpty) {
      if (log ?? false) {
        print(data.trim());
      }
      err += data;
    }
  }).asFuture();

  final exitCode = await process.exitCode;

  if (exitCode != 0) {
    print('Error: Failed to run \'$cmd\' in $dir!');
    print(err);

    return {
      'stdout': out,
      'stderr': err,
      'exitCode': exitCode,
    };
  }

  return {
    'stdout': out,
    'stderr': err,
    'exitCode': exitCode,
  };
}
