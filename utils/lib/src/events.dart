// ignore: public_member_api_docs
import 'package:flutter/material.dart';

// ignore: public_member_api_docs
abstract class ChangedEvent {}

// ignore: public_member_api_docs
class TagsUpdateEvent extends ChangedEvent {}

// ignore: public_member_api_docs
class UpdatesUpdateEvent extends ChangedEvent {}

// ignore: public_member_api_docs
class FetchAppDataEvent extends ChangedEvent {
  // ignore: public_member_api_docs
  FetchAppDataEvent({this.feature});

  // ignore: public_member_api_docs
  final String feature;
}

// ignore: public_member_api_docs
class PushMaterialPageRouteEvent extends ChangedEvent {
  // ignore: public_member_api_docs
  PushMaterialPageRouteEvent(this.page);

  // ignore: public_member_api_docs
  final Widget page;
}

// ignore: public_member_api_docs
class LoadingStatusChangedEvent extends ChangedEvent {
  // ignore: public_member_api_docs
  LoadingStatusChangedEvent(this.key);

  // ignore: public_member_api_docs
  final String key;
}

// ignore: public_member_api_docs
class ThemeChangedEvent extends ChangedEvent {}

// ignore: public_member_api_docs
class DateUpdateEvent extends ChangedEvent {
  // ignore: public_member_api_docs
  DateUpdateEvent(this.date);

  // ignore: public_member_api_docs
  final DateTime date;
}
