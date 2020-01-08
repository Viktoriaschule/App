library storage;

export 'package:ginko/plugins/storage/storage_io.dart'
    if (dart.library.js) 'package:ginko/plugins/storage/storage_web.dart';
