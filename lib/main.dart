import 'package:flutter/foundation.dart'
    show debugDefaultTargetPlatformOverride;
import 'package:flutter/material.dart';
import 'package:flutter_event_bus/flutter_event_bus.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:viktoriaapp/app/app_page.dart';
import 'package:viktoriaapp/login/login_page.dart';
import 'package:viktoriaapp/models/models.dart';
import 'package:viktoriaapp/plugins/platform/platform.dart';
import 'package:viktoriaapp/plugins/storage/storage.dart';
import 'package:viktoriaapp/utils/notifications.dart';
import 'package:viktoriaapp/utils/static.dart';
import 'package:viktoriaapp/utils/theme.dart';
import 'package:viktoriaapp/utils/pages.dart';

Future main() async {
  if (Platform().isDesktop) {
    debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;
  }

  WidgetsFlutterBinding.ensureInitialized();

  timeago.setLocaleMessages('de', timeago.DeMessages());

  Static.storage = Storage();
  await Static.storage.init();
  await setupDateFormats();

  runApp(
    EventBusWidget(
      child: Pages(
        child: MaterialApp(
          title: 'ViktoriaApp',
          theme: theme,
          darkTheme: darkTheme,
          routes: <String, WidgetBuilder>{
            '/': (context) => AppPage(),
            '/${Keys.login}': (context) => LoginPageWrapper(),
          },
          builder: (context, child) => Scaffold(
            body: NotificationsWidget(
              child: child,
            ),
          ),
        ),
      ),
    ),
  );
}
