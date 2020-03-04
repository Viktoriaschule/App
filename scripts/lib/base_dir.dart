import 'dart:io';

/// The base dir of the project
String get baseDir => Directory.current.path.endsWith('scripts') ? '..' : '.';
