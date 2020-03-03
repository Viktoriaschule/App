import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:utils/utils.dart';

import 'app_frame.dart';

/// Start the app
Future startApp(String name) async {
  if (Platform().isDesktop) {
    debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;
  }

  WidgetsFlutterBinding.ensureInitialized();

  timeago.setLocaleMessages('de', timeago.DeMessages());

  Static.storage = Storage();
  await Static.storage.init();
  await setupDateFormats();
  runApp(AppFrame(
    appName: name,
  ));
}
