import 'package:flutter/foundation.dart'
    show debugDefaultTargetPlatformOverride;
import 'package:flutter/material.dart';
import 'package:viktoriaapp/aixformation/aixformation_page.dart';
import 'package:viktoriaapp/app/app_page.dart';
import 'package:viktoriaapp/cafetoria/cafetoria_page.dart';
import 'package:viktoriaapp/calendar/calendar_page.dart';
import 'package:viktoriaapp/login/login_page.dart';
import 'package:viktoriaapp/plugins/platform/platform.dart';
import 'package:viktoriaapp/plugins/storage/storage.dart';
import 'package:viktoriaapp/settings/settings_page.dart';
import 'package:viktoriaapp/utils/static.dart';
import 'package:viktoriaapp/utils/theme.dart';
import 'package:viktoriaapp/models/models.dart';
import 'package:timeago/timeago.dart' as timeago;

Future main() async {
  if (Platform().isDesktop) {
    debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;
  }

  WidgetsFlutterBinding.ensureInitialized();

  timeago.setLocaleMessages('de', timeago.DeMessages());

  Static.storage = Storage();
  await Static.storage.init();
  await setupDateFormats();

  runApp(MaterialApp(
    title: 'Ginko',
    theme: theme,
    darkTheme: darkTheme,
    routes: <String, WidgetBuilder>{
      '/': (context) => AppPage(),
      '/${Keys.timetable}': (context) => AppPage(
            page: 2,
            loading: false,
          ),
      '/${Keys.substitutionPlan}': (context) => AppPage(
            page: 0,
            loading: false,
          ),
      '/${Keys.login}': (context) => LoginPageWrapper(),
      '/${Keys.cafetoria}': (context) => CafetoriaPage(),
      '/${Keys.aiXformation}': (context) => AiXformationPage(),
      '/${Keys.calendar}': (context) => CalendarPage(),
      '/${Keys.settings}': (context) => SettingsPage(),
    },
  ));
}
