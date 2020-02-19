library firebase;

export 'package:viktoriaapp/plugins/firebase/firebase_io.dart'
    if (dart.library.js) 'package:viktoriaapp/plugins/firebase/firebase_web.dart';
