import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:viktoriaapp/models/models.dart';
import 'package:viktoriaapp/utils/static.dart';

// ignore: public_member_api_docs
abstract class Loader<LoaderType> {
  // ignore: public_member_api_docs
  Loader(this.key);

  // ignore: public_member_api_docs
  final String key;

  /// Sets if all request should be posts
  ///
  /// If this is activated, the [postBody] function must be overrode to set the post body
  bool alwaysPost = false;

  /// Defines the post body in case that [alwaysPost] is true
  dynamic get postBody => null;

  // ignore: public_member_api_docs
  LoaderType parsedData;

  // ignore: public_member_api_docs, type_annotate_public_apis, always_declare_return_types
  LoaderType fromJSON(json);

  // ignore: public_member_api_docs
  LoaderType get data => parsedData;

  /// The raw downloaded json string
  String _rawData;

  bool _loadedFromOnline = false;

  // ignore: public_member_api_docs
  void loadOffline() {
    if (hasStoredData) {
      parsedData = fromJSON(Static.storage.getJSON(key));
    }
  }

  /// Download the data from the api and returns the status code
  Future<int> loadOnline(BuildContext context,
      {String username,
      String password,
      bool force = false,
      bool post = false,
      Map<String, dynamic> body,
      bool store = true,
      bool autoLogin = true}) async {
    if (_loadedFromOnline && !force) {
      return StatusCodes.success;
    }
    username ??= Static.user.username;
    password ??= Static.user.password;
    const baseUrl = 'https://vsa.fingeg.de';
    try {
      final dio = Dio()
        ..options = BaseOptions(
          headers: {
            'authorization':
                'Basic ${base64.encode(utf8.encode('$username:$password'))}',
          },
          responseType: ResponseType.plain,
          connectTimeout: 20000,
          receiveTimeout: 20000,
        );
      Response response;
      if (alwaysPost || post) {
        response = await dio.post(
          '$baseUrl/$key',
          data: body ?? postBody,
        );
      } else {
        response = await dio.get(
          '$baseUrl/$key',
        );
      }
      final data = json.decode(response.toString());
      final successfully = response.statusCode == 200;
      if (store) {
        if (successfully) {
          if (data != null) {
            _rawData = response.toString();
            parsedData = fromJSON(data);
          }
          save();
          _loadedFromOnline = true;
        } else {
          print('$key failed to load');
        }
      }
      if (response.statusCode == StatusCodes.unauthorized &&
          autoLogin &&
          context != null) {
        await Navigator.of(context).pushReplacementNamed('/${Keys.login}');
      }
      return response.statusCode;
    } on DioError catch (e) {
      print(e);
      if (e.response != null) {
        print(
            '${e.response.statusMessage} (${e.response.statusCode}): ${e.response.data}');
        if (e.response.statusCode == StatusCodes.unauthorized &&
            autoLogin &&
            context != null) {
          await Navigator.of(context).pushReplacementNamed('/${Keys.login}');
        }
        return e.response.statusCode;
      }
      rethrow;
    }
  }

  // ignore: public_member_api_docs
  void save() {
    Static.storage.setString(key, _rawData);
  }

  // ignore: public_member_api_docs
  void clear() {
    parsedData = null;
    _loadedFromOnline = false;
    save();
  }

  /// Check if there is any data stored
  bool get hasStoredData =>
      Static.storage.has(key) && Static.storage.getString(key) != null;

  /// Check if there is any data loaded
  bool get hasLoadedData => data != null;
}
