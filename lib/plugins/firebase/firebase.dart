library firebase;

export 'package:ginko/plugins/firebase/firebase_io.dart'
    if (dart.library.js) 'package:ginko/plugins/firebase/firebase_web.dart';
