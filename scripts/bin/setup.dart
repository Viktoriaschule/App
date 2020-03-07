import 'create_app.dart' as create_app;
import 'icons.dart' as icons;
import 'packages.dart' as packages;

Future main() async {
  await icons.main([]);
  await create_app.main(['viktoriaapp', 'viktoriamanagement']);
  await packages.main([]);
}
