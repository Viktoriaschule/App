import 'dart:io';
import 'command.dart';

Future main(List<String> arguments) async {
  var logDebug = false;
  if (arguments.isNotEmpty) {
    logDebug = arguments[0] == '-d' || arguments[0] == '--debug';
  }

  await runCommand('flutter pub get', log: logDebug);
  final error = (await runCommand(
        'flutter test',
        dir: 'app',
        log: logDebug,
      ))['exitCode'] !=
      1;

  if (error) {
    exit(1);
  }
}
