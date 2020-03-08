import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_event_bus/flutter_event_bus.dart';
import 'package:utils/utils.dart';

import 'static.dart';
import 'updates_model.dart';

// ignore: public_member_api_docs
abstract class Loader<LoaderType> {
  // ignore: public_member_api_docs
  Loader(this.key, this.event);

  // ignore: public_member_api_docs
  final String key;

  /// The download event
  final ChangedEvent event;

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

  /// If the loader must be updated
  bool get forceUpdate => false;

  /// The raw downloaded json string
  String _rawData;

  bool _loadedFromOnline = false;

  LoaderResponse<LoaderType> _fromJSON(String rawJson) {
    try {
      final data = fromJSON(json.decode(rawJson));
      return LoaderResponse<LoaderType>(
          data: data, statusCode: StatusCode.success);
      // ignore: avoid_catches_without_on_clauses
    } catch (e) {
      print('Failed to parse $key: $e');
      return LoaderResponse<LoaderType>(
          data: null, statusCode: StatusCode.wrongFormat);
    }
  }

  /// Update the loader if the update hash has changed
  Future<StatusCode> update(BuildContext context, Updates newUpdates,
      {bool force = false}) async {
    final hash = newUpdates.getUpdate(key);
    if (force ||
        forceUpdate ||
        Static.updates.data.getUpdate(key) != hash ||
        !hasLoadedData) {
      final status = await loadOnline(context, force: force);
      if (status == StatusCode.success) {
        Static.updates.data.setUpdate(key, hash);
      }
      return status;
    }
    return StatusCode.success;
  }

  // ignore: public_member_api_docs
  StatusCode loadOffline(BuildContext context) {
    if (hasStoredData) {
      preLoad(context);
      final parsed = _fromJSON(Static.storage.getString(key));
      parsedData = parsed.data;
      if (parsed.statusCode != StatusCode.success) {
        Static.storage.remove(key);
      }
      afterLoad();
      _sendLoadedEvent(Pages.of(context), EventBus.of(context));
      return parsed.statusCode;
    }
    return StatusCode.success;
  }

  /// Download the data from the api and returns the status code
  Future<StatusCode> loadOnline(BuildContext context,
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

  /// A function that can be override to process some operations with a valid context before the load function starts
  void preLoad(BuildContext context) => {};

  /// A function that can be override to process some custom loader operation after the load function finished
  ///
  /// This function will be called after the download finished, but before the finished loading event will be fired
  void afterLoad() => {};

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
      return LoaderResponse(statusCode: StatusCode.success);
    }

    final pages = context != null ? Pages.of(context) : null;
    final eventBus = context != null ? EventBus.of(context) : null;

    // Inform the gui about this loading process
    _sendLoadingEvent(pages, eventBus);

    // Run the pre load for custom loader operations
    preLoad(context);

    username ??= Static.user.username;
    password ??= Static.user.password;
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
          '$viktoriaAppBaseURL/$key',
          data: body ?? postBody,
        );
      } else {
        response = await dio.get(
          '$viktoriaAppBaseURL/$key',
        );
      }
      final successfully = response.statusCode == 200;
      final statusCodes = [getStatusCode(response.statusCode)];
      if (store) {
        if (successfully) {
          _rawData = response.toString();
          final parsed = _fromJSON(_rawData);
          parsedData = parsed.data ?? parsedData;
          statusCodes.add(parsed.statusCode);
          if (parsed.statusCode == StatusCode.success) {
            save();
          }
          _loadedFromOnline = true;
        } else {
          print('$key failed to load');
        }
      }
      if (response.statusCode == 401 && autoLogin && context != null) {
        await Navigator.of(context).pushReplacementNamed('/${Keys.login}');
      }

      dynamic data;
      try {
        data = json.decode(response.toString());
        statusCodes.add(StatusCode.success);
        // ignore: avoid_catches_without_on_clauses
      } catch (e) {
        statusCodes.add(StatusCode.wrongFormat);
        print('Failed parse $key: $e');
      }

      afterLoad();
      _sendLoadedEvent(pages, eventBus);
      final status = reduceStatusCodes(statusCodes);
      if (status != StatusCode.success) {
        print(
            'Did not successfully updated $key: $status (http: ${response.statusCode})');
      }
      return LoaderResponse(data: data, statusCode: status);
    } on DioError catch (e) {
      afterLoad();
      _sendLoadedEvent(pages, eventBus);
      switch (e.type) {
        case DioErrorType.RESPONSE:
          if (e.response.statusCode == 401) {
            print('Failed to load $key: Unauthorized');
            if (autoLogin && context != null) {
              await Navigator.of(context)
                  .pushReplacementNamed('/${Keys.login}');
            }
            return LoaderResponse(statusCode: StatusCode.unauthorized);
          }
          print('Failed to load $key: ${e.type}:\n${e.error}');
          return LoaderResponse(statusCode: StatusCode.failed);
        case DioErrorType.DEFAULT:
          if (e.error is SocketException) {
            print('Failed to load $key: offline');
            return LoaderResponse(statusCode: StatusCode.offline);
          }
          print('Failed to load $key: ${e.type}:\n${e.error}');
          return LoaderResponse(statusCode: StatusCode.failed);
        default:
          print('Failed to load $key: ${e.type}:\n${e.error}');
          return LoaderResponse(statusCode: StatusCode.failed);
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
    _rawData = null;
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
  final StatusCode statusCode;
}