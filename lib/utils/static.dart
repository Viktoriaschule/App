import 'package:ginko/loaders/aixformation.dart';
import 'package:ginko/loaders/cafetoria.dart';
import 'package:ginko/loaders/calendar.dart';
import 'package:ginko/loaders/subjects.dart';
import 'package:ginko/loaders/substitution_plan.dart';
import 'package:ginko/loaders/tags.dart';
import 'package:ginko/loaders/timetable.dart';
import 'package:ginko/loaders/updates.dart';
import 'package:ginko/models/models.dart';
import 'package:ginko/plugins/firebase/firebase.dart';
import 'package:ginko/plugins/storage/storage.dart';

// ignore: avoid_classes_with_only_static_members
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
