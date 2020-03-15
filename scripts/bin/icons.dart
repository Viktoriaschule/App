import 'dart:io';

import 'package:dio/dio.dart';
import 'package:process_run/cmd_run.dart';
import 'package:process_run/which.dart';
import 'package:scripts/base_dir.dart';

Future main(List<String> arguments) async {
  if (whichSync('inkscape') == null) {
    throw Exception('Inkscape isn\'t installed');
  }
  // Copy the white svg to a green svg
  final logoWhitePath = '$baseDir/images/logo_white.svg';
  final logoGreenPath = '$baseDir/images/logo_green.svg';
  final logoManagementWhitePath = '$baseDir/images/logo_management_white.svg';
  final logoManagementGreenPath = '$baseDir/images/logo_management_green.svg';

  final logoWhite = await File(logoWhitePath).readAsString();
  final logoGreen = logoWhite.replaceAll('ffffff', '5bc638');
  await File(logoGreenPath).writeAsString(logoGreen);

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
  final logoGreenContent = RegExp('<g.*<\/g>')
      .firstMatch(logoGreen.replaceAll(RegExp('\n|\r'), ''))
      .group(0);
  final logoWhiteContent = RegExp('<g.*<\/g>')
      .firstMatch(logoWhite.replaceAll(RegExp('\n|\r'), ''))
      .group(0);

  final managementLogoGreen = [
    '<svg width="1024" height="1024" viewBox="0 0 1024 1024" xmlns="http://www.w3.org/2000/svg">',
    '\t<rect fill="#ffffff" x="192" y="12" width="640" height="1000"/>',
    '\t<g fill="#000000" transform="scale(42.666) translate(0.5,0)">',
    '\t\t$iPadPath',
    '\t</g>',
    '\t<g transform="scale(0.5) translate(512, 448)">',
    '\t\t$logoGreenContent',
    '\t</g>',
    '</svg>',
  ].join('\n');

  final managementLogoWhite = [
    '<svg width="1024" height="1024" viewBox="0 0 1024 1024" xmlns="http://www.w3.org/2000/svg">',
    '\t<g fill="#ffffff" transform="scale(42.666) translate(0.5,0)">',
    '\t\t$iPadPath',
    '\t</g>',
    '\t<g transform="scale(0.5) translate(512, 448)">',
    '\t\t$logoWhiteContent',
    '\t</g>',
    '</svg>',
  ].join('\n');

  await File(logoManagementGreenPath).writeAsString(managementLogoGreen);
  await File(logoManagementWhitePath).writeAsString(managementLogoWhite);

  await svgToPng(
    logoWhitePath,
    '$baseDir/images/logo_white_1024x1024.png',
    1024,
  );
  await svgToPng(
    logoManagementWhitePath,
    '$baseDir/images/logo_management_white_1024x1024.png',
    1024,
  );
  await svgToPng(
    logoGreenPath,
    '$baseDir/images/logo_green_1024x1024.png',
    1024,
  );
  await svgToPng(
    logoManagementGreenPath,
    '$baseDir/images/logo_management_green_1024x1024.png',
    1024,
  );
  await svgToPng(
    logoGreenPath,
    '$baseDir/images/logo_green_512x512.png',
    512,
  );
  await svgToPng(
    logoManagementGreenPath,
    '$baseDir/images/logo_management_green_512x512.png',
    512,
  );
  await svgToPng(
    logoGreenPath,
    '$baseDir/images/logo_green_192x192.png',
    192,
  );
  await svgToPng(
    logoManagementGreenPath,
    '$baseDir/images/logo_management_green_192x192.png',
    192,
  );
  await svgToPng(
    logoGreenPath,
    '$baseDir/images/logo_green_16x16.png',
    16,
  );
  await svgToPng(
    logoManagementGreenPath,
    '$baseDir/images/logo_management_green_16x16.png',
    16,
  );
}

Future svgToPng(String inPath, String outPath, int size) async {
  await run(
    'inkscape',
    [
      '-z',
      '-e',
      outPath,
      '-w',
      size.toString(),
      '-h',
      size.toString(),
      inPath,
    ],
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
