// ignore: public_member_api_docs
import 'package:flutter/material.dart';

// ignore: public_member_api_docs
abstract class Event {}

// ignore: public_member_api_docs
class TimetableUpdateEvent extends Event {}

// ignore: public_member_api_docs
class SubstitutionPlanUpdateEvent extends Event {}

// ignore: public_member_api_docs
class CafetoriaUpdateEvent extends Event {}

// ignore: public_member_api_docs
class CalendarUpdateEvent extends Event {}

// ignore: public_member_api_docs
class AiXformationUpdateEvent extends Event {}

// ignore: public_member_api_docs
class SubjectsUpdateEvent extends Event {}

// ignore: public_member_api_docs
class TagsUpdateEvent extends Event {}

// ignore: public_member_api_docs
class UpdatesUpdateEvent extends Event {}

// ignore: public_member_api_docs
class FetchAppDataEvent extends Event {}

// ignore: public_member_api_docs
class PushMaterialPageRouteEvent extends Event {
  // ignore: public_member_api_docs
  PushMaterialPageRouteEvent(this.page);

  // ignore: public_member_api_docs
  final Widget page;
}

// ignore: public_member_api_docs
class LoadingStatusChangedEvent extends Event {
  // ignore: public_member_api_docs
  LoadingStatusChangedEvent(this.key);

  // ignore: public_member_api_docs
  final String key;
}

// ignore: public_member_api_docs
class ThemeChangedEvent extends Event {}
