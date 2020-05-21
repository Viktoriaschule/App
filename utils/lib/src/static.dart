import 'loading/tags_loader.dart';
import 'loading/updates.dart';
import 'plugins/firebase/firebase.dart';
import 'plugins/storage/storage.dart';
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
  static UpdatesLoader updates = UpdatesLoader();

  // ignore: public_member_api_docs
  static FirebaseMessaging firebaseMessaging = FirebaseMessaging();
}
