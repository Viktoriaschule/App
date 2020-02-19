library pwa;

export 'package:viktoriaapp/plugins/pwa/pwa_io.dart'
    if (dart.library.js) 'package:viktoriaapp/plugins/pwa/pwa_web.dart';
