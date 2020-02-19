library platform;

export 'package:viktoriaapp/plugins/platform/platform_io.dart'
    if (dart.library.js) 'package:viktoriaapp/plugins/platform/platform_web.dart';
