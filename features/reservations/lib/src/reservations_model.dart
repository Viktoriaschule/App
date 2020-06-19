import 'package:flutter/material.dart';
import 'package:reservations/src/reservations_localizations.dart';
import 'package:timetable/timetable.dart';
import 'package:utils/utils.dart';

/// All school devices in the management system
class Reservations {
  // ignore: public_member_api_docs
  Reservations({@required this.reservations, this.groups});

  /// Creates the calendar from json map
  factory Reservations.fromJson(Map<String, dynamic> json) => Reservations(
        reservations: json['reservations']
            .map<Reservation>((json) => Reservation.fromJson(json))
            .toList(),
        groups: json['groups']
            .map<ReservationGroup>((json) => ReservationGroup.fromJson(json))
            .toList(),
      );

  /// All loaded reservations
  final List<Reservation> reservations;

  /// All reservation groups for the current user
  final List<ReservationGroup> groups;

  /// Returns all future reservations for the current user
  List<Reservation> get myFutureReservations => reservations
      .where((r) =>
          r.participant == Static.user.username &&
          r.date.add(Duration(hours: 1)).isAfter(DateTime.now()))
      .toList();
}

/// One school device
class Reservation {
  // ignore: public_member_api_docs
  Reservation({
    this.id,
    this.groupID,
    this.timetableID,
    this.timetableSubject,
    this.participant,
    this.date,
    this.priority,
    this.iPadGroup,
    this.created,
    this.modified,
  });

  /// Creates calendar event from json map
  factory Reservation.fromJson(Map<String, dynamic> json) => Reservation(
        id: json['id'],
        groupID: json['groupID'],
        timetableID: json['timetableID'],
        participant: json['participant'],
        date: DateTime.parse(json['date']),
        priority: Priority.fromJson(json['priority']),
        iPadGroup: json['iPadGroup'],
        created: DateTime.parse(json['created']),
        modified: DateTime.parse(json['modified']),
      );

  /// The reservation identifier
  final String id;

  /// If the reservation is part of a group, this is the id
  final int groupID;

  /// If the reservation is pinned to a timetable subject, this is the id
  final String timetableID;

  /// If [timetableID] is set, this is the timetable object with the id
  final TimetableSubject timetableSubject;

  /// The participant who created the reservation
  final String participant;

  /// The date and time of the start point of the reservation
  final DateTime date;

  /// The reservation priority
  final Priority priority;

  /// Which iPad group is reserved
  final int iPadGroup;

  /// The creation date
  final DateTime created;

  /// The last modified date
  final DateTime modified;

  // ignore: public_member_api_docs
  Map<String, dynamic> toMap() => {
        'id': id,
        'groupID': groupID,
        'timetableID': timetableID,
        'participant': participant,
        'date': date.toIso8601String(),
        'priority': priority.toMap(),
        'iPadGroup': iPadGroup,
        'created': created.toIso8601String(),
        'modified': modified.toIso8601String(),
      };
}

/// The different priority levels
enum PriorityLevel {
  /// For unspecific reservations
  low,

  /// The default priority
  normal,

  /// If it is important to have the iPads (Only with reason)
  high,
}

const _displayNames = [
  ReservationsLocalizations.low,
  ReservationsLocalizations.normal,
  ReservationsLocalizations.high,
];

// ignore: public_member_api_docs
extension PriorityNames on PriorityLevel {
  /// Returns the display name of the priority
  String get displayName => _displayNames[index];
}

/// The reservation priority
class Priority {
  // ignore: public_member_api_docs
  Priority({this.level, this.description});

  // ignore: public_member_api_docs
  factory Priority.fromJson(Map<String, dynamic> json) => Priority(
        level: PriorityLevel.values[json['level']],
        description: json['description'],
      );

  /// The reservation priority level
  PriorityLevel level;

  /// The priority description
  String description;

  // ignore: public_member_api_docs
  Map<String, dynamic> toMap() => {
        'level': level.index,
        'description': description,
      };
}

/// A battery entry of one device to a specif time
class ReservationGroup {
  // ignore: public_member_api_docs
  ReservationGroup({this.id, this.reservations, this.name, this.participant});

  // ignore: public_member_api_docs
  factory ReservationGroup.fromJson(Map<String, dynamic> json) =>
      ReservationGroup(
        id: json['id'],
        name: json['name'],
        participant: json['participant'],
        reservations: (json['reservations'] ?? []).cast<Reservation>().toList(),
      );

  /// The reservation group id
  int id;

  /// All reservations in this group
  List<Reservation> reservations;

  /// The display name of the group
  String name;

  /// The participant who created this group
  String participant;

  // ignore: public_member_api_docs
  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'participant': participant,
        'reservations': reservations.map((e) => e.toMap())
      };
}

// ignore: public_member_api_docs
class TimetableSubjects {
  // ignore: public_member_api_docs
  TimetableSubjects({this.subjects});

  // ignore: public_member_api_docs
  factory TimetableSubjects.fromJson(Map<String, dynamic> json) =>
      TimetableSubjects(
        subjects: json['subjects']
            .map<TimetableSubject>((json) => TimetableSubject.fromJson(json, 0))
            .toList(),
      );

  // ignore: public_member_api_docs
  final List<TimetableSubject> subjects;

  /// Returns the loaded subject with the given [id]
  TimetableSubject getSubjectWithId(String id) {
    final subjects = this.subjects.where((s) => s.id == id).toList();

    if (subjects.isNotEmpty) {
      return subjects.first;
    }
    return null;
  }
}
