import 'dart:io';

import 'package:dio/dio.dart';

import 'command.dart';

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
  final logoGreenG =
      RegExp('<g.*<\/g>').firstMatch(logoGreen.replaceAll('\n', '')).group(0);

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
  await File('images/logo_green_192x192.png').writeAsBytes(await post(
    'https://fingeg.de/converter/png?width=192&height=192',
    {'img': logoGreen},
  ));
  await File('images/logo_management.png').writeAsBytes(await post(
    'https://fingeg.de/converter/png?width=1024&height=1024',
    {'img': managementLogo},
  ));
  await File('images/logo_management_192x192.png').writeAsBytes(await post(
    'https://fingeg.de/converter/png?width=192&height=192',
    {'img': managementLogo},
  ));

  // Create app icons
  await runCommand(
    'flutter',
    ['pub', 'get'],
    log: logDebug,
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
  );

  //await Directory('go/assets/').create();
  await File('images/logo_white.png')
      .copy('android/app/src/main/res/drawable/logo_white.png');
  //await File('images/logo_green.png').copy('go/assets/icon.png');
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
