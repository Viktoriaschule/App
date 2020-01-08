import 'dart:convert';
import 'dart:io';
import 'command.dart';

Future main(List<String> arguments) async {
  var logDebug = false;
  if (arguments.isNotEmpty) {
    logDebug = arguments[0] == '-d' || arguments[0] == '--debug';
  }

  // Copy the white svg to a green svg
  final fileLogoWhite = File('images/logo_white.svg');
  final fileLogoGreen = File('images/logo_green.svg');

  final logoWhite = await fileLogoWhite.readAsString();
  final logoGreen = logoWhite.replaceAll('ffffff', '5bc638');
  await fileLogoGreen.writeAsString(logoGreen);

  // Create PNGs from SVGs
  print('Get pngs..');
  final greenPng = await post('https://fingeg.de/converter/png?width=1024&height=1024', {'img': logoGreen});
  final greenPngSmall = await post('https://fingeg.de/converter/png?width=192&height=192', {'img': logoGreen});
  final whitePng = await post('https://fingeg.de/converter/png?width=1024&height=1024', {'img': logoWhite});
  print('... successfully');
  await File('images/logo_white.png').writeAsBytes(whitePng);
  await File('images/logo_green.png').writeAsBytes(greenPng);
  await File('images/logo_green_192x192.png').writeAsBytes(greenPngSmall);

  // Create app icons
  await runCommand(
    'flutter pub get',
    log: logDebug,
  );
  await runCommand(
    'flutter pub run flutter_launcher_icons:main -f icons_white.yaml',
    log: logDebug,
  );
  await runCommand(
    'flutter pub run flutter_launcher_icons:main -f icons_green.yaml',
    log: logDebug,
  );

  await Directory('go/assets/').create();
  await File('images/logo_white.png').copy('android/app/src/main/res/drawable/logo_white.png');
  await File('images/logo_green.png').copy('go/assets/icon.png');
  
}

Future<List<int>> post(String url, Map<String, dynamic> body) async {

  final httpClient = HttpClient();

  // Send request
  final request = await httpClient.postUrl(Uri.parse(url));
  request.headers.set('content-type', 'application/json');
  request.add(utf8.encode(json.encode(body)));
  final response = await request.close();

  // Get answer
  final _downloadData = <int>[];
  final stream = response.listen(_downloadData.addAll);
  await stream.asFuture();
  await stream.cancel();

  httpClient.close();
  return _downloadData;
}
