import 'package:flutter/material.dart';
import 'package:utils/utils.dart';

/// All tags handler for the features have to be subclasses of this handler
abstract class TagsHandler {
  /// Synchronize all local tags with the given tags from the server
  void syncFromServer(Tags tags, BuildContext context);

  /// Synchronize all tags that are newer than the given server tags
  Map<String, dynamic> syncToServer(Tags tags);
}
