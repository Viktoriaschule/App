import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_event_bus/flutter_event_bus.dart';
import 'package:utils/utils.dart';

import '../static.dart';
import 'updates_model.dart';

// ignore: public_member_api_docs
enum HttpMethod {
  // ignore: constant_identifier_names, public_member_api_docs
  GET,
  // ignore: constant_identifier_names, public_member_api_docs
  POST,
  // ignore: public_member_api_docs, constant_identifier_names
  PUT,
  // ignore: public_member_api_docs, constant_identifier_names
  DELETE,
}

// ignore: public_member_api_docs
abstract class Loader<LoaderType> {
  // ignore: public_member_api_docs
  Loader(this.key, this.event);

  // ignore: public_member_api_docs
  String key;

  /// The download event
  final ChangedEvent event;

  /// Sets if all request should be posts
  ///
  /// If this is activated, the [defaultBody] function must be overrode to set the post body
  HttpMethod get forceMethod => null;

  /// Defines the default request body in case the http method is not GET
  dynamic get defaultBody => null;

  // ignore: public_member_api_docs
  LoaderType parsedData;

  // ignore: public_member_api_docs, type_annotate_public_apis, always_declare_return_types
  LoaderType fromJSON(json);

  // ignore: public_member_api_docs
  LoaderType get data => parsedData;

  /// If the loader must be updated
  bool get forceUpdate => false;

  /// The base url for all request
  BaseUrl get baseUrl => BaseUrl.viktoriaApp;

  /// The raw downloaded json string
  String _rawData;

  bool _loadedFromOnline = false;

  /// Tries to parse the json into the model structure
  LoaderResponse<LoaderType> tryParseJSON(String rawJson) {
    try {
      final data = fromJSON(json.decode(rawJson));
      return LoaderResponse<LoaderType>(
          data: data, statusCode: StatusCode.success);
      // ignore: avoid_catches_without_on_clauses
    } catch (e, stacktrace) {
      print('Failed to parse $key: $e\n$stacktrace');
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
      final status = await loadOnline(context, force: true);
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
      _rawData = Static.storage.getString(key);
      final parsed = tryParseJSON(_rawData);
      parsedData = parsed.data;
      if (parsed.statusCode != StatusCode.success) {
        Static.storage.remove(key);
      }
      afterLoad();
      _sendLoadedEvent(LoadingState.of(context), EventBus.of(context));
      return parsed.statusCode;
    }
    return StatusCode.success;
  }

  /// Download the data from the api and returns the status code
  Future<StatusCode> loadOnline(
    BuildContext context, {
    String username,
    String password,
    bool force = false,
    HttpMethod method = HttpMethod.GET,
    Map<String, dynamic> body,
    Map<String, dynamic> queryParameters,
    bool store = true,
    bool showLoginOnWrongCredentials = true,
    String path,
  }) async =>
      (await _load(
        context,
        username: username,
        password: password,
        force: force,
        method: method,
        body: body,
        queryParameters: queryParameters,
        store: store,
        showLoginOnWrongCredentials: showLoginOnWrongCredentials,
        path: path,
      ))
          .statusCode;

  /// Fetches the data
  Future<LoaderResponse<LoaderType>> fetch(
    BuildContext context, {
        String username,
        String password,
        HttpMethod method = HttpMethod.GET,
        Map<String, dynamic> body,
        Map<String, dynamic> queryParameters,
        bool showLoginOnWrongCredentials = true,
        String path,
      }) =>
      _load(
        context,
        username: username,
        password: password,
        force: true,
        method: method,
        body: body,
        queryParameters: queryParameters,
        store: false,
        showLoginOnWrongCredentials: showLoginOnWrongCredentials,
        path: path,
      );

  /// A function that can be override to process some operations with a valid context before the load function starts
  void preLoad(BuildContext context) => {};

  /// A function that can be override to process some custom loader operation after the load function finished
  ///
  /// This function will be called after the download finished, but before the finished loading event will be fired
  void afterLoad() => {};

  /// Download the data from the api and returns the status code
  Future<LoaderResponse<LoaderType>> _load(
    BuildContext context, {
        String username,
        String password,
        bool force = false,
        HttpMethod method = HttpMethod.GET,
        Map<String, dynamic> body,
        Map<String, dynamic> queryParameters,
        bool store = true,
        bool showLoginOnWrongCredentials = true,
        String path,
      }) async {
    if (_loadedFromOnline && !force) {
      return LoaderResponse(statusCode: StatusCode.success);
    }

    final start = DateTime.now();

    final loadingStates = context != null ? LoadingState.of(context) : null;
    final eventBus = context != null ? EventBus.of(context) : null;

    // Inform the gui about this loading process
    _sendLoadingEvent(loadingStates, eventBus);

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
      final url = '${baseUrl.url}/${path ?? key}';
      switch (forceMethod ?? method) {
        case HttpMethod.GET:
          response = await dio.get(
            url,
            queryParameters: queryParameters,
          );
          break;
        case HttpMethod.POST:
          response = await dio.post(
            url,
            data: body ?? defaultBody,
            queryParameters: queryParameters,
          );
          break;
        case HttpMethod.PUT:
          response = await dio.put(
            url,
            data: body ?? defaultBody,
            queryParameters: queryParameters,
          );
          break;
        case HttpMethod.DELETE:
          response = await dio.delete(
            url,
            data: body ?? defaultBody,
            queryParameters: queryParameters,
          );
          break;
      }
      final successfully = response.statusCode == 200;
      final statusCodes = [getStatusCode(response.statusCode)];
      if (store) {
        if (successfully) {
          _rawData = response.toString();
          final parsed = tryParseJSON(_rawData);
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
      if (response.statusCode == 401 &&
          showLoginOnWrongCredentials &&
          context != null) {
        await Navigator.of(context).pushReplacementNamed('/${Keys.login}');
      }
      LoaderType data;
      if (!store) {
        data = tryParseJSON(response.toString())?.data;
      }

      try {
        afterLoad();
        // ignore: avoid_catches_without_on_clauses
      } catch (e, stacktrace) {
        print('Failed run after load of $key: $e\n$stacktrace');
        statusCodes.add(StatusCode.wrongFormat);
      }

      _sendLoadedEvent(loadingStates, eventBus);
      final status = reduceStatusCodes(statusCodes);
      if (status != StatusCode.success) {
        print(
            'Did not successfully updated $key: $status (http: ${response
                .statusCode})');
      }
      print(
          'Loaded $key: ${DateTime
              .now()
              .difference(start)
              .inMilliseconds}ms');
      return LoaderResponse<LoaderType>(
          data: data, statusCode: status, rawData: response.toString());
    } on DioError catch (e) {
      afterLoad();
      _sendLoadedEvent(loadingStates, eventBus);
      print(
          'Failed loading $key: ${DateTime.now().difference(start).inMilliseconds}ms');
      switch (e.type) {
        case DioErrorType.RESPONSE:
          if (e.response.statusCode == 401) {
            print('Failed to load $key: Unauthorized');
            if (showLoginOnWrongCredentials && context != null) {
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
  void _setLoading(
      LoadingState loadingStates, EventBus eventBus, bool isLoading) {
    loadingStates?.setLoading(key, isLoading);
    eventBus?.publish(LoadingStatusChangedEvent(key));
  }

  // ignore: public_member_api_docs
  void _sendLoadingEvent(LoadingState loadingStates, EventBus eventBus) {
    _setLoading(loadingStates, eventBus, true);
  }

  // ignore: public_member_api_docs
  void _sendLoadedEvent(LoadingState loadingStates, EventBus eventBus) {
    eventBus?.publish(event);
    _setLoading(loadingStates, eventBus, false);
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
  LoaderResponse({this.data, this.statusCode, this.rawData});

  /// The parsed data
  final T data;

  /// The raw http response
  final String rawData;

  /// The request http status
  final StatusCode statusCode;
}
