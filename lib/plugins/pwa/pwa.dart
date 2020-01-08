library pwa;

export 'package:ginko/plugins/pwa/pwa_io.dart'
    if (dart.library.js) 'package:ginko/plugins/pwa/pwa_web.dart';
