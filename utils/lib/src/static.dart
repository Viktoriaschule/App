// ignore: avoid_classes_with_only_static_members

import 'package:aixformation/aixformation.dart';
import 'package:cafetoria/cafetoria.dart';
import 'package:calendar/calendar.dart';
import 'package:substitution_plan/substitution_plan.dart';
import 'package:timetable/timetable.dart';

import 'plugins/firebase/firebase.dart';
import 'plugins/storage/storage.dart';
import 'subjects_loader.dart';
import 'tags_loader.dart';
import 'updates.dart';
import 'user_model.dart';

/// Static class
/// handles all app wide static objects
class Static {
  // ignore: public_member_api_docs
  static Storage storage;

  // ignore: public_member_api_docs
  static User user = User();

  // ignore: public_member_api_docs
  static TagsLoader tags = TagsLoader();

  // ignore: public_member_api_docs
  static TimetableLoader timetable = TimetableLoader();

  // ignore: public_member_api_docs
  static SubstitutionPlanLoader substitutionPlan = SubstitutionPlanLoader();

  // ignore: public_member_api_docs
  static CalendarLoader calendar = CalendarLoader();

  // ignore: public_member_api_docs
  static CafetoriaLoader cafetoria = CafetoriaLoader();

  // ignore: public_member_api_docs
  static AiXformationLoader aiXformation = AiXformationLoader();

  // ignore: public_member_api_docs
  static UpdatesLoader updates = UpdatesLoader();

  // ignore: public_member_api_docs
  static SubjectsLoader subjects = SubjectsLoader();

  // ignore: public_member_api_docs
  static FirebaseMessaging firebaseMessaging = FirebaseMessaging();

  // ignore: public_member_api_docs
  static Selection selection = Selection();
}

typedef VoidCallback = void Function();
typedef FutureCallback = Future Function();
typedef FutureCallbackShouldRender = Future Function(bool shouldRender);
