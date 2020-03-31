import 'create_app.dart' as create_app;
import 'packages.dart' as packages;

Future main() async {
  await create_app.main(['viktoriaapp', 'viktoriamanagement']);
  await packages.main([]);
}
