import 'dart:io';

import 'package:dio/dio.dart';
import 'package:scripts/command.dart';

Future main(List<String> arguments) async {
  var logDebug = false;
  if (arguments.isNotEmpty) {
    logDebug = arguments[0] == '-d' || arguments[0] == '--debug';
  }

  // Copy the white svg to a green svg
  final fileLogoWhite = File('images/logo_white.svg');
  final fileLogoGreen = File('images/logo_green.svg');
  final fileLogoManagement = File('images/logo_management.svg');

  final logoWhite = await fileLogoWhite.readAsString();
  final logoGreen = logoWhite.replaceAll('ffffff', '5bc638');
  await fileLogoGreen.writeAsString(logoGreen);

  final iPadPath = RegExp('<path.*\/>')
      .firstMatch((await Dio().get(
              'https://raw.githubusercontent.com/Templarian/MaterialDesign/master/svg/tablet-ipad.svg'))
          .toString()
          .replaceAll(
            '<?xml version="1.0" encoding="UTF-8"?><!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.1//EN" "http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">',
            '',
          )
          .replaceAll(
            ' id="mdi-tablet-ipad"',
            '',
          )
          .replaceAll(
            ' xmlns:xlink="http://www.w3.org/1999/xlink" version="1.1"',
            '',
          ))
      .group(0);
  final logoGreenG = RegExp('<g.*<\/g>')
      .firstMatch(logoGreen.replaceAll(RegExp('\n|\r'), ''))
      .group(0);

  final managementLogo = [
    '<svg width="1024" height="1024" viewBox="0 0 1024 1024" xmlns="http://www.w3.org/2000/svg">',
    '\t<g transform="scale(42.666) translate(0.5,0)">',
    '\t\t$iPadPath',
    '\t</g>',
    '\t<g transform="scale(0.5) translate(512, 448)">',
    '\t\t$logoGreenG',
    '\t</g>',
    '</svg>',
  ].join('\n');

  await fileLogoManagement.writeAsString(managementLogo);

  // Create PNGs from SVGs
  await File('images/logo_white.png').writeAsBytes(await post(
    'https://fingeg.de/converter/png?width=1024&height=1024',
    {'img': logoWhite},
  ));
  await File('images/logo_green.png').writeAsBytes(await post(
    'https://fingeg.de/converter/png?width=1024&height=1024',
    {'img': logoGreen},
  ));
  await File('images/logo_green_16x16.png').writeAsBytes(await post(
    'https://fingeg.de/converter/png?width=16&height=16',
    {'img': logoGreen},
  ));
  await File('images/logo_green_192x192.png').writeAsBytes(await post(
    'https://fingeg.de/converter/png?width=192&height=192',
    {'img': logoGreen},
  ));
  await File('images/logo_green_512x512.png').writeAsBytes(await post(
    'https://fingeg.de/converter/png?width=512&height=512',
    {'img': logoGreen},
  ));
  await File('images/logo_management.png').writeAsBytes(await post(
    'https://fingeg.de/converter/png?width=1024&height=1024',
    {'img': managementLogo},
  ));
  await File('images/logo_management_16x16.png').writeAsBytes(await post(
    'https://fingeg.de/converter/png?width=16&height=16',
    {'img': managementLogo},
  ));
  await File('images/logo_management_192x192.png').writeAsBytes(await post(
    'https://fingeg.de/converter/png?width=192&height=192',
    {'img': managementLogo},
  ));
  await File('images/logo_management_512x512.png').writeAsBytes(await post(
    'https://fingeg.de/converter/png?width=512&height=512',
    {'img': managementLogo},
  ));

  final webDirectory = Directory('apps/viktoriaapp/web');
  if (!webDirectory.existsSync()) {
    webDirectory.createSync();
  }
  final webIconsDirectory = Directory('${webDirectory.path}/icons');
  if (!webIconsDirectory.existsSync()) {
    webIconsDirectory.createSync();
  }

  await File('images/logo_green_192x192.png')
      .copy('apps/viktoriaapp/web/icons/Icon-192.png');
  await File('images/logo_green_512x512.png')
      .copy('apps/viktoriaapp/web/icons/Icon-512.png');
  await File('images/logo_green_16x16.png')
      .copy('apps/viktoriaapp/web/favicon.png');

  // Create app icons
  await runCommand(
    'flutter',
    ['pub', 'get'],
    log: logDebug,
    dir: 'apps/viktoriaapp',
  );
  await runCommand(
    'flutter',
    [
      'pub',
      'run',
      'flutter_launcher_icons:main',
      '-f',
      'icons_white.yaml',
    ],
    log: logDebug,
    dir: 'apps/viktoriaapp',
  );
  await runCommand(
    'flutter',
    [
      'pub',
      'run',
      'flutter_launcher_icons:main',
      '-f',
      'icons_green.yaml',
    ],
    log: logDebug,
    dir: 'apps/viktoriaapp',
  );
}

Future<List<int>> post(String url, Map<String, dynamic> body) async =>
    (await Dio().post<List<int>>(
      url,
      options: Options(
        responseType: ResponseType.bytes,
      ),
      data: body,
    ))
        .data;
