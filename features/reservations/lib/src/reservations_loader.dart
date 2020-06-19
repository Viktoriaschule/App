import 'package:flutter/material.dart';
import 'package:reservations/src/reservations_events.dart';
import 'package:reservations/src/reservations_keys.dart';
import 'package:reservations/src/reservations_model.dart';
import 'package:utils/utils.dart';

/// IPad list loader class
class ReservationsLoader extends Loader<Reservations> {
  // ignore: public_member_api_docs
  ReservationsLoader()
      : super(ReservationsKeys.reservations, ReservationsUpdateEvent());

  @override
  // ignore: type_annotate_public_apis, always_declare_return_types
  fromJSON(json) => Reservations.fromJson(json);

  @override
  StatusCode loadOffline(BuildContext context) => reduceStatusCodes([
        super.loadOffline(context),
        timetableManagement.loadOffline(context),
      ]);

  BuildContext _context;

  @override
  void preLoad(BuildContext context) => _context = context;

  @override
  void afterLoad() => timetableManagement.loadOnline(_context);

  @override
  BaseUrl get baseUrl => BaseUrl.viktoriaManagement;

  /// The loader to manage the reservations
  final _ReservationListLoader reservationManagement = _ReservationListLoader();

  /// The loader to manage the reservation groups
  final _ReservationGroupsLoader reservationGroupsManagement =
      _ReservationGroupsLoader();

  /// The loader to manage the timetable subjects for the reservations
  final _ReservationTimetableLoader timetableManagement =
      _ReservationTimetableLoader();
}

/// All the loader management for the reservations:
///   - new reservation
///   - edit reservation
///   - delete reservation
class _ReservationListLoader extends Loader<_RequestResponse> {
  // ignore: public_member_api_docs
  _ReservationListLoader()
      : super(
          ReservationsKeys.reservationList,
          ReservationsUpdateEvent(),
        );

  @override
  BaseUrl get baseUrl => BaseUrl.viktoriaManagement;

  @override
  // ignore: type_annotate_public_apis, always_declare_return_types
  fromJSON(json) => _RequestResponse.fromJson(json);

  Future<StatusCode> _request(
      BuildContext context, Reservation reservation, HttpMethod method) async {
    final response = await fetch(
      context,
      method: method,
      body: reservation.toMap(),
    );
    if (response.data.error != null &&
        response.data.error.isNotEmpty &&
        response.statusCode == StatusCode.success) {
      return StatusCode.failed;
    }
    return response.statusCode;
  }

  /// Creates a new reservation
  ///
  /// The reservation id will be overridden by the server
  Future<StatusCode> newReservation(
    BuildContext context,
    Reservation reservation,
  ) =>
      _request(
        context,
        reservation,
        HttpMethod.POST,
      );

  /// Edit a reservation with the given id
  Future<StatusCode> editReservation(
          BuildContext context, Reservation reservation) =>
      _request(
        context,
        reservation,
        HttpMethod.PUT,
      );

  /// Edit a reservation with the given id
  Future<StatusCode> deleteReservation(
          BuildContext context, Reservation reservation) =>
      _request(
        context,
        reservation,
        HttpMethod.DELETE,
      );
}

/// All the loader management for the reservations:
///   - new reservation
///   - edit reservation
///   - delete reservation
class _ReservationGroupsLoader extends Loader<_RequestResponse> {
  // ignore: public_member_api_docs
  _ReservationGroupsLoader()
      : super(
          ReservationsKeys.reservationGroups,
          ReservationsUpdateEvent(),
        );

  @override
  BaseUrl get baseUrl => BaseUrl.viktoriaManagement;

  @override
  // ignore: type_annotate_public_apis, always_declare_return_types
  fromJSON(json) => _RequestResponse.fromJson(json);

  Future<StatusCode> _request(
      BuildContext context, ReservationGroup group, HttpMethod method) async {
    final response = await fetch(
      context,
      method: method,
      body: group.toMap(),
    );
    if (response.data.error != null &&
        response.data.error.isNotEmpty &&
        response.statusCode == StatusCode.success) {
      return StatusCode.failed;
    }
    return response.statusCode;
  }

  /// Creates a new reservation
  ///
  /// The reservation id will be overridden by the server
  Future<StatusCode> newGroup(
    BuildContext context,
    ReservationGroup group,
  ) =>
      _request(
        context,
        group,
        HttpMethod.POST,
      );

  /// Edit a reservation with the given id
  Future<StatusCode> editGroup(BuildContext context, ReservationGroup group) =>
      _request(
        context,
        group,
        HttpMethod.PUT,
      );

  /// Edit a reservation with the given id
  Future<StatusCode> deleteGroup(
          BuildContext context, ReservationGroup group) =>
      _request(
        context,
        group,
        HttpMethod.DELETE,
      );
}

/// All the loader management for the reservations:
///   - new reservation
///   - edit reservation
///   - delete reservation
class _ReservationTimetableLoader extends Loader<TimetableSubjects> {
  // ignore: public_member_api_docs
  _ReservationTimetableLoader()
      : super(
          ReservationsKeys.reservationTimetable,
          ReservationsUpdateEvent(),
        );

  List<String> _ids;

  // ignore: avoid_setters_without_getters
  set ids(List<String> ids) => _ids = ids;

  @override
  HttpMethod get forceMethod => shouldGet ? HttpMethod.GET : HttpMethod.POST;

  bool shouldGet = false;

  @override
  Map<String, dynamic> get defaultBody => {'ids': _ids};

  @override
  // ignore: type_annotate_public_apis, always_declare_return_types
  fromJSON(json) => TimetableSubjects.fromJson(json);

  /// Returns all
  Future<LoaderResponse<TimetableSubjects>> getSubjectsInUnit(
    BuildContext context,
    String group,
    int day,
    int unit,
  ) async {
    shouldGet = true;
    final res = await fetch(context, queryParameters: {
      'group': group,
      'day': day,
      'unit': unit,
    });
    shouldGet = false;
    return res;
  }
}

class _RequestResponse {
  _RequestResponse({this.status, this.error});

  /// Creates the calendar from json map
  factory _RequestResponse.fromJson(Map<String, dynamic> json) =>
      _RequestResponse(status: json['status'], error: json['error']);

  final String status;
  final String error;
}
