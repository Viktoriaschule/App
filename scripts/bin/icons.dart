import 'dart:io';

import 'package:dio/dio.dart';
import 'package:scripts/base_dir.dart';

Future main(List<String> arguments) async {
  // Copy the white svg to a green svg
  final fileLogoWhite = File('$baseDir/images/logo_white.svg');
  final fileLogoGreen = File('$baseDir/images/logo_green.svg');
  final fileLogoManagementWhite =
      File('$baseDir/images/logo_management_white.svg');
  final fileLogoManagementGreen =
      File('$baseDir/images/logo_management_green.svg');

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

  final managementLogoGreen = [
    '<svg width="1024" height="1024" viewBox="0 0 1024 1024" xmlns="http://www.w3.org/2000/svg">',
    '\t<rect fill="#ffffff" x="192" y="12" width="640" height="1000"/>',
    '\t<g fill="#000000" transform="scale(42.666) translate(0.5,0)">',
    '\t\t$iPadPath',
    '\t</g>',
    '\t<g transform="scale(0.5) translate(512, 448)">',
    '\t\t$logoGreenG',
    '\t</g>',
    '</svg>',
  ].join('\n');

  final managementLogoWhite = managementLogoGreen
      .replaceAll('5bc638', 'ffffff')
      .replaceAll('000000', 'ffffff')
      .replaceAll(RegExp('\t<rect.*\/>\n'), '');

  await fileLogoManagementGreen.writeAsString(managementLogoGreen);
  await fileLogoManagementWhite.writeAsString(managementLogoWhite);

  print('Converting SVGs to PNGs');

  // Create PNGs from SVGs
  await File('$baseDir/images/logo_white_1024x1024.png')
      .writeAsBytes(await post(
    'https://fingeg.de/converter/png?width=1024&height=1024',
    {'img': logoWhite},
  ));
  await File('$baseDir/images/logo_green_1024x1024.png')
      .writeAsBytes(await post(
    'https://fingeg.de/converter/png?width=1024&height=1024',
    {'img': logoGreen},
  ));
  await File('$baseDir/images/logo_green_512x512.png').writeAsBytes(await post(
    'https://fingeg.de/converter/png?width=512&height=512',
    {'img': logoGreen},
  ));
  await File('$baseDir/images/logo_green_192x192.png').writeAsBytes(await post(
    'https://fingeg.de/converter/png?width=192&height=192',
    {'img': logoGreen},
  ));
  await File('$baseDir/images/logo_green_16x16.png').writeAsBytes(await post(
    'https://fingeg.de/converter/png?width=16&height=16',
    {'img': logoGreen},
  ));
  await File('$baseDir/images/logo_management_white_1024x1024.png')
      .writeAsBytes(await post(
    'https://fingeg.de/converter/png?width=1024&height=1024',
    {'img': managementLogoWhite},
  ));
  await File('$baseDir/images/logo_management_green_1024x1024.png')
      .writeAsBytes(await post(
    'https://fingeg.de/converter/png?width=1024&height=1024',
    {'img': managementLogoGreen},
  ));
  await File('$baseDir/images/logo_management_green_512x512.png')
      .writeAsBytes(await post(
    'https://fingeg.de/converter/png?width=512&height=512',
    {'img': managementLogoGreen},
  ));
  await File('$baseDir/images/logo_management_green_192x192.png')
      .writeAsBytes(await post(
    'https://fingeg.de/converter/png?width=192&height=192',
    {'img': managementLogoGreen},
  ));
  await File('$baseDir/images/logo_management_green_16x16.png')
      .writeAsBytes(await post(
    'https://fingeg.de/converter/png?width=16&height=16',
    {'img': managementLogoGreen},
  ));
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
