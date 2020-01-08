import 'package:flutter/material.dart';
import 'package:ginko/loaders/loader.dart';
import 'package:ginko/models/models.dart';

/// AiXformationLoader class
class AiXformationLoader extends Loader {
  // ignore: public_member_api_docs
  AiXformationLoader() : super(Keys.aiXformation);

//TODO: Add the Aixformation api to the server and remove this override
  @override
  Future<int> loadOnline(BuildContext context,
      {String username,
      String password,
      bool force = false,
      bool post = false,
      Map<String, dynamic> body,
      bool store = true,
      bool autoLogin = true}) async {
    parsedData = AiXformation(posts: [], date: DateTime.now());
    return StatusCodes.success;
  }

  @override
  // ignore: type_annotate_public_apis, always_declare_return_types
  fromJSON(json) => AiXformation.fromJSON(json);
}
