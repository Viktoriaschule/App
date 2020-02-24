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
import 'package:viktoriaapp/utils/events.dart';
import 'package:viktoriaapp/utils/notifications.dart';
import 'package:viktoriaapp/utils/pages.dart';
import 'package:viktoriaapp/utils/static.dart';
import 'package:viktoriaapp/utils/theme.dart';

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
        child: ThemeWidget(
          child: App(),
        ),
      ),
    ),
  );
}

// ignore: public_member_api_docs
class App extends StatefulWidget {
  @override
  _AppState createState() => _AppState();
}

class _AppState extends Interactor<App> {
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'ViktoriaApp',
        theme: ThemeWidget.of(context).theme,
        routes: <String, WidgetBuilder>{
          '/': (context) => AppPage(),
          '/${Keys.login}': (context) => LoginPageWrapper(),
        },
        builder: (context, child) => Scaffold(
          body: NotificationsWidget(
            child: child,
          ),
        ),
      );

  @override
  Subscription subscribeEvents(EventBus eventBus) =>
      eventBus.respond<ThemeChangedEvent>((event) => setState(() => null));
}
