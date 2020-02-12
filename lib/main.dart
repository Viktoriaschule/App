import 'package:flutter/foundation.dart'
    show debugDefaultTargetPlatformOverride;
import 'package:flutter/material.dart';
import 'package:ginko/aixformation/aixformation_page.dart';
import 'package:ginko/app/app_page.dart';
import 'package:ginko/cafetoria/cafetoria_page.dart';
import 'package:ginko/calendar/calendar_page.dart';
import 'package:ginko/login/login_page.dart';
import 'package:ginko/plugins/platform/platform.dart';
import 'package:ginko/plugins/storage/storage.dart';
import 'package:ginko/settings/settings_page.dart';
import 'package:ginko/utils/static.dart';
import 'package:ginko/utils/theme.dart';
import 'package:ginko/models/models.dart';
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
