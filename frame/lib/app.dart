// ignore: public_member_api_docs
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_event_bus/flutter_event_bus.dart';
import 'package:utils/utils.dart';

import 'app_page.dart';
import 'login_page.dart';
import 'notifications.dart';

// ignore: public_member_api_docs
class App extends StatefulWidget {
  // ignore: public_member_api_docs
  const App({
    @required this.appName,
    Key key,
  }) : super(key: key);

  // ignore: public_member_api_docs
  final String appName;

  @override
  _AppState createState() => _AppState();
}

class _AppState extends Interactor<App> {
  @override
  Widget build(BuildContext context) => AnnotatedRegion<SystemUiOverlayStyle>(
        value: ThemeWidget.of(context).brightness == Brightness.dark
            ? SystemUiOverlayStyle.dark.copyWith(
                statusBarIconBrightness: Brightness.light,
                systemNavigationBarColor:
                    ThemeWidget.of(context).theme.snackBarTheme.backgroundColor,
              )
            : SystemUiOverlayStyle.light.copyWith(
                systemNavigationBarColor:
                    ThemeWidget.of(context).theme.backgroundColor,
              ),
        child: MaterialApp(
          title: widget.appName,
          theme: ThemeWidget.of(context).theme,
          routes: <String, WidgetBuilder>{
            '/': (context) => AppPage(),
            '/${Keys.login}': (context) => LoginPageWrapper(),
          },
          builder: (context, child) => Scaffold(
            body: ThemeUpdateWidget(
              child: NotificationsWidget(
                child: child,
              ),
            ),
          ),
        ),
      );

  @override
  Subscription subscribeEvents(EventBus eventBus) =>
      eventBus.respond<ThemeChangedEvent>((event) => setState(() => null));
}
