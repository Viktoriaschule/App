library storage;

export 'package:viktoriaapp/plugins/storage/storage_io.dart'
    if (dart.library.js) 'package:viktoriaapp/plugins/storage/storage_web.dart';
