library platform;

export 'package:ginko/plugins/platform/platform_io.dart'
    if (dart.library.js) 'package:ginko/plugins/platform/platform_web.dart';
