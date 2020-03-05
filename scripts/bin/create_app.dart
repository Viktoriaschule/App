import 'dart:io';

import 'package:mustache_template/mustache.dart';
import 'package:process_run/process_run.dart';
import 'package:scripts/base_dir.dart';
import 'package:yaml/yaml.dart';

// ignore_for_file: no_adjacent_strings_in_list

Future main(List<String> arguments) async {
  if (arguments.isEmpty) {
    throw Exception('Expected the name(s) of the app config file(s)');
  }
  for (final argument in arguments) {
    if (!File('$baseDir/apps/$argument.yaml').existsSync()) {
      throw Exception('$argument is not a valid app config file');
    }
    final config =
        loadYaml(File('$baseDir/apps/$argument.yaml').readAsStringSync());
    final String name = config['name'];
    final String fullName = config['full_name'];
    final String version = config['version'];
    final String package = config['package'];
    final YamlMap firebaseWeb = config['firebase_web'];
    final YamlMap greenIcons = config['logo_green'];
    final YamlMap whiteIcons = config['logo_white'];
    final List<Feature> features = config['features']
        .map((e) => Feature(e['name'], e['full_name']))
        .toList()
        .cast<Feature>();
    final googleServicesPath = '$baseDir/apps/$name-google-services.json';
    final keyPropertiesPath = '$baseDir/apps/$name-key.properties';
    if (!File(googleServicesPath).existsSync()) {
      throw Exception('Missing $googleServicesPath');
    }
    if (!File(keyPropertiesPath).existsSync()) {
      throw Exception('Missing $keyPropertiesPath');
    }

    for (final iconPath
        in [...greenIcons.values, ...whiteIcons.values].toList()) {
      if (!File('$baseDir/apps/$iconPath').existsSync()) {
        throw Exception('Missing $baseDir/apps/$iconPath');
      }
    }

    void log(s) {
      if (arguments.length > 1) {
        print('[$fullName] $s');
      } else {
        print(s);
      }
    }

    final appDir = Directory('$baseDir/apps/$name');
    if (appDir.existsSync()) {
      log('Deleting old app directory');
      appDir.deleteSync(recursive: true);
    }
    log('Creating app using flutter create');
    await run(
      'flutter',
      [
        'create',
        '-ajava',
        '--org=${(package.split('.')..removeLast()).join('.')}',
        '--project-name=${package.split('.').last}',
        name,
      ],
      workingDirectory: '$baseDir/apps',
    );
    final List<String> filesToRemove = [
      'ios',
      'test',
      'README.md',
      '${package.split('.').last}.iml',
      '.metadata',
      '.idea',
      '.gitignore',
    ];
    log('Removing unused files');
    for (final path in filesToRemove) {
      File('${appDir.path}/$path').deleteSync(recursive: true);
    }
    log('Copying template files');
    File('${appDir.path}/android/app/src/main/java/${package.replaceAll('.', '/')}/Application.java')
        .writeAsStringSync(Template(
                File('$baseDir/scripts/templates/Application.java.tmpl')
                    .readAsStringSync())
            .renderString({
      'package': package,
    }));
    File('${appDir.path}/android/app/src/main/java/${package.replaceAll('.', '/')}/MainActivity.java')
        .writeAsStringSync(Template(
                File('$baseDir/scripts/templates/MainActivity.java.tmpl')
                    .readAsStringSync())
            .renderString({
      'package': package,
    }));
    File('${appDir.path}/lib/main.dart').writeAsStringSync(Template(
            File('$baseDir/scripts/templates/main.dart.tmpl')
                .readAsStringSync())
        .renderString({
      'fullName': fullName,
    }));
    File('${appDir.path}/pubspec.yaml').writeAsStringSync(Template(
            File('$baseDir/scripts/templates/pubspec.yaml.tmpl')
                .readAsStringSync())
        .renderString({
      'name': name,
      'version': version,
    }));
    File('${appDir.path}/web/manifest.json').writeAsStringSync(Template(
            File('$baseDir/scripts/templates/manifest.json.tmpl')
                .readAsStringSync())
        .renderString({
      'fullName': fullName,
    }));
    File('${appDir.path}/web/sw.js').writeAsStringSync(
        File('$baseDir/scripts/templates/sw.js.tmpl').readAsStringSync());

    log('Modifying Android sources');
    final androidManifestPath =
        '${appDir.path}/android/app/src/main/AndroidManifest.xml';
    File(androidManifestPath).writeAsStringSync((File(androidManifestPath)
            .readAsStringSync()
            .replaceAll(
              'android:name="io.flutter.app.FlutterApplication"',
              'android:name=".Application"',
            )
            .replaceAll(
              'android:label="${package.split('.').last}"',
              'android:label="$fullName"',
            )
            .replaceAll(
              [
                '            <intent-filter>',
                '                <action android:name="android.intent.action.MAIN"/>',
                '                <category android:name="android.intent.category.LAUNCHER"/>',
                '            </intent-filter>',
              ].join('\n'),
              [
                '            <intent-filter>',
                '                <action android:name="android.intent.action.MAIN"/>',
                '                <action android:name="android.intent.action.VIEW"/>',
                '                <category android:name="android.intent.category.LAUNCHER"/>',
                '            </intent-filter>',
                '            <intent-filter>',
                '                <action android:name="FLUTTER_NOTIFICATION_CLICK"/>',
                '                <category android:name="android.intent.category.DEFAULT"/>',
                '            </intent-filter>',
              ].join('\n'),
            )
            .split('\n')
              ..insert(
                  2,
                  [
                    '    <uses-permission android:name="android.permission.INTERNET"/>',
                    '    <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>',
                    '    <uses-permission android:name="android.permission.WAKE_LOCK"/>',
                    '    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>',
                  ].join('\n')))
        .join('\n'));

    File('$baseDir/frame/android/gradle/wrapper/gradle-wrapper.properties')
        .copySync(
            '${appDir.path}/android/gradle/wrapper/gradle-wrapper.properties');

    final androidBuildGradlePath = '${appDir.path}/android/build.gradle';
    File(androidBuildGradlePath).writeAsStringSync(
        (File(androidBuildGradlePath).readAsStringSync().split('\n')
              ..insert(8,
                  '        classpath \'com.google.gms:google-services:4.3.3\''))
            .join('\n'));

    final appBuildGradlePath = '${appDir.path}/android/app/build.gradle';
    final appBuildGradleContent = File(appBuildGradlePath)
        .readAsStringSync()
        .replaceAll(
          'android {',
          [
            'def keystoreProperties = new Properties()',
            'def keystorePropertiesFile = rootProject.file(\'key.properties\')',
            'if (keystorePropertiesFile.exists()) {',
            '  keystoreProperties.load(new FileInputStream(keystorePropertiesFile))',
            '}',
            '',
            'android {',
          ].join('\n'),
        )
        .replaceAll(
          '        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).\n',
          '',
        )
        .replaceAll(
          [
            '    buildTypes {',
            '        release {',
            '            // TODO: Add your own signing config for the release build.',
            '            // Signing with the debug keys for now, so `flutter run --release` works.',
            '            signingConfig signingConfigs.debug',
            '        }',
            '    }',
          ].join('\n'),
          [
            '    signingConfigs {',
            '        release {',
            '            keyAlias keystoreProperties[\'keyAlias\']',
            '            keyPassword keystoreProperties[\'keyPassword\']',
            '            storeFile file(keystoreProperties[\'storeFile\'])',
            '            storePassword keystoreProperties[\'storePassword\']',
            '        }',
            '    }',
            '    buildTypes {',
            '        release {',
            '            signingConfig signingConfigs.release',
            '            shrinkResources true',
            '            minifyEnabled true',
            '            proguardFiles getDefaultProguardFile(\'proguard-android.txt\'),',
            '                    \'proguard-rules.pro\'',
            '        }',
            '    }',
          ].join('\n'),
        );
    File(appBuildGradlePath)
        .writeAsStringSync((appBuildGradleContent.split('\n')
              ..addAll([
                'dependencies {',
                '    implementation \'com.google.firebase:firebase-messaging:20.1.1\'',
                '}',
                '',
                'apply plugin: \'com.google.gms.google-services\''
              ]))
            .join('\n'));

    log('Modifying web sources');
    final indexHtmlPath = '${appDir.path}/web/index.html';
    File(indexHtmlPath).writeAsStringSync(
      File(indexHtmlPath)
          .readAsStringSync()
          .replaceAll(
            '</head>',
            [
              '  <meta name="theme-color" content="#64A441"/>',
              '  <script src="https://www.gstatic.com/firebasejs/6.6.2/firebase-app.js"></script>',
              '  <script src="https://www.gstatic.com/firebasejs/6.6.2/firebase-messaging.js"></script>',
              '</head>',
            ].join('\n'),
          )
          .replaceAll('<title>${package.split('.').last}</title>',
              '<title>$fullName</title>')
          .replaceAll(
              'content="${package.split('.').last}"', 'content="$fullName"')
          .replaceAll('content="A new Flutter project."', 'content="$fullName"')
          .replaceAll(
            [
              '    if (\'serviceWorker\' in navigator) {',
              '      window.addEventListener(\'load\', function () {',
              '        navigator.serviceWorker.register(\'/flutter_service_worker.js\');',
              '      });',
              '    }',
            ].join('\n'),
            [
              '    if (window.location.hash.length > 2) {',
              '      window.location.hash = \'#/\';',
              '      window.location.reload();',
              '    }',
              '    if (\'serviceWorker\' in navigator) {',
              '      window.addEventListener(\'load\', function () {',
              '        navigator.serviceWorker.register(\'/flutter_service_worker.js\');',
              '        const firebaseConfig = {',
              ...firebaseWeb.keys
                  .map((e) => '          $e: \'${firebaseWeb[e]}\','),
              '        };',
              '        firebase.initializeApp(firebaseConfig);',
              '        navigator.serviceWorker.register(\'sw.js\')',
              '          .then((registration) => {',
              '            if (firebase.messaging() != null) {',
              '              firebase.messaging().useServiceWorker(registration);',
              '            }',
              '          });',
              '      });',
              '      window.addEventListener(\'beforeinstallprompt\', (e) => {',
              '        e.preventDefault();',
              '        window.deferredPrompt = e;',
              '      });',
              '    }',
            ].join('\n'),
          ),
    );

    log('Copying icons');
    File('${appDir.path}/icons_green.yaml').writeAsStringSync([
      'flutter_icons:',
      '  android: true',
      '  ios: false',
      '  image_path: "../${greenIcons[1024]}"'
    ].join('\n'));
    File('${appDir.path}/icons_white.yaml').writeAsStringSync([
      'flutter_icons:',
      '  android: "logo_white"',
      '  ios: false',
      '  image_path: "../${whiteIcons[1024]}"'
    ].join('\n'));

    await File('$baseDir/apps/${greenIcons[512]}')
        .copy('${appDir.path}/web/icons/Icon-512.png');
    await File('$baseDir/apps/${greenIcons[192]}')
        .copy('${appDir.path}/web/icons/Icon-192.png');
    await File('$baseDir/apps/${greenIcons[16]}')
        .copy('${appDir.path}/web/favicon.png');

    // Create app icons
    await run(
      'flutter',
      ['pub', 'get'],
      workingDirectory: appDir.path,
    );
    await run(
      'flutter',
      [
        'pub',
        'run',
        'flutter_launcher_icons:main',
        '-f',
        'icons_white.yaml',
      ],
      workingDirectory: appDir.path,
    );
    await run(
      'flutter',
      [
        'pub',
        'run',
        'flutter_launcher_icons:main',
        '-f',
        'icons_green.yaml',
      ],
      workingDirectory: appDir.path,
    );

    log('Copying keys');
    File(googleServicesPath)
        .copySync('${appDir.path}/android/app/google-services.json');
    File(keyPropertiesPath).copySync('${appDir.path}/android/key.properties');

    log('Creating run configurations');
    File('$baseDir/.idea/runConfigurations/${fullName}_Debug.xml')
        .writeAsStringSync(Template(File(
                    '$baseDir/scripts/templates/RunConfigurationDebug.xml.tmpl')
                .readAsStringSync())
            .renderString({
      'name': name,
      'fullName': fullName,
    }));
    File('$baseDir/.idea/runConfigurations/${fullName}_Release.xml')
        .writeAsStringSync(Template(File(
                    '$baseDir/scripts/templates/RunConfigurationRelease.xml.tmpl')
                .readAsStringSync())
            .renderString({
      'name': name,
      'fullName': fullName,
    }));

    log('Finished');
  }
}

class Feature {
  Feature(
    this.name,
    this.fullName,
  );

  final String name;
  final String fullName;
}
