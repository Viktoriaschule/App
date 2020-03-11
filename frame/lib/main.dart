import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_event_bus/flutter_event_bus.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:utils/utils.dart';

import 'app.dart';
import 'features.dart';

/// Start the app
Future startApp({
  @required String name,
  @required List<Feature> features,
}) async {
  if (Platform().isDesktop) {
    debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;
  }

  WidgetsFlutterBinding.ensureInitialized();

  timeago.setLocaleMessages('de', timeago.DeMessages());

  Static.storage = Storage();
  await Static.storage.init();

  runApp(EventBusWidget(
    child: Features(
      features: features,
      child: LoadingState(
        child: ThemeWidget(
          child: App(
            appName: name,
          ),
        ),
      ),
    ),
  ));
}
