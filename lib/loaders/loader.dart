import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_event_bus/flutter_event_bus.dart';
import 'package:viktoriaapp/models/models.dart';
import 'package:viktoriaapp/utils/events.dart';
import 'package:viktoriaapp/utils/pages.dart';
import 'package:viktoriaapp/utils/static.dart';

// ignore: public_member_api_docs
abstract class Loader<LoaderType> {
  // ignore: public_member_api_docs
  Loader(this.key, this.event);

  // ignore: public_member_api_docs
  final String key;

  /// The download event
  final Event event;

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
  void loadOffline(BuildContext context) {
    if (hasStoredData) {
      parsedData = fromJSON(Static.storage.getJSON(key));
      _sendLoadedEvent(Pages.of(context), EventBus.of(context));
    }
  }

  /// Download the data from the api and returns the status code
  Future<StatusCodes> loadOnline(BuildContext context,
          {String username,
          String password,
          bool force = false,
          bool post = false,
          Map<String, dynamic> body,
          bool store = true,
          bool autoLogin = true}) async =>
      (await _load(context,
              username: username,
              password: password,
              force: force,
              post: post,
              body: body,
              store: store,
              autoLogin: autoLogin))
          .statusCode;

  /// Fetches the data
  Future<LoaderResponse> fetch(BuildContext context,
          {String username,
          String password,
          bool post = false,
          Map<String, dynamic> body,
          bool autoLogin = true}) =>
      _load(context,
          username: username,
          password: password,
          force: true,
          post: post,
          body: body,
          store: false,
          autoLogin: autoLogin);

  /// Download the data from the api and returns the status code
  Future<LoaderResponse> _load(BuildContext context,
      {String username,
      String password,
      bool force = false,
      bool post = false,
      Map<String, dynamic> body,
      bool store = true,
      bool autoLogin = true}) async {
    if (_loadedFromOnline && !force) {
      return LoaderResponse(statusCode: StatusCodes.success);
    }

    final pages = context != null ? Pages.of(context) : null;
    final eventBus = context != null ? EventBus.of(context) : null;

    _sendLoadingEvent(pages, eventBus);
    username ??= Static.user.username;
    password ??= Static.user.password;
    const baseUrl = 'https://vsa.fingeg.de';
    try {
      if (username == null || password == null) {
        throw DioError(
          type: DioErrorType.RESPONSE,
          response: Response(statusCode: 401),
        );
      }
      final dio = Dio()
        ..options = BaseOptions(
          headers: {
            'authorization':
                'Basic ${base64.encode(utf8.encode('$username:$password'))}',
          },
          responseType: ResponseType.plain,
          connectTimeout: 3000,
          receiveTimeout: 3000,
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
      if (response.statusCode == 401 && autoLogin && context != null) {
        await Navigator.of(context).pushReplacementNamed('/${Keys.login}');
      }
      _sendLoadedEvent(pages, eventBus);
      return LoaderResponse(
          data: data, statusCode: getStatusCode(response.statusCode));
    } on DioError catch (e) {
      _sendLoadedEvent(pages, eventBus);
      switch (e.type) {
        case DioErrorType.RESPONSE:
          if (e.response.statusCode == 401) {
            if (autoLogin && context != null) {
              await Navigator.of(context)
                  .pushReplacementNamed('/${Keys.login}');
            }
            return LoaderResponse(statusCode: StatusCodes.unauthorized);
          }
          return LoaderResponse(statusCode: StatusCodes.failed);
        case DioErrorType.DEFAULT:
          if (e.error is SocketException) {
            return LoaderResponse(statusCode: StatusCodes.offline);
          }
          return LoaderResponse(statusCode: StatusCodes.failed);
        default:
          return LoaderResponse(statusCode: StatusCodes.failed);
      }
    }
  }

  /// Sets the page loading state
  void _setLoading(Pages pages, EventBus eventBus, bool isLoading) {
    pages?.setLoading(key, isLoading);
    eventBus?.publish(LoadingStatusChangedEvent(key));
  }

  // ignore: public_member_api_docs
  void _sendLoadingEvent(Pages pages, EventBus eventBus) {
    _setLoading(pages, eventBus, true);
  }

  // ignore: public_member_api_docs
  void _sendLoadedEvent(Pages pages, EventBus eventBus) {
    eventBus?.publish(event);
    _setLoading(pages, eventBus, false);
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

// ignore: public_member_api_docs
class LoaderResponse<T> {
  // ignore: public_member_api_docs
  LoaderResponse({this.data, this.statusCode});

  // ignore: public_member_api_docs
  final T data;
  // ignore: public_member_api_docs
  final StatusCodes statusCode;
}
