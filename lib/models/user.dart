import 'package:viktoriaapp/models/models.dart';
import 'package:viktoriaapp/utils/static.dart';

/// User class
/// describes a user
class User {
  // ignore: public_member_api_docs
  User();

  // ignore: public_member_api_docs
  String get username => Static.storage.getString(Keys.username);

  // ignore: public_member_api_docs
  String get password => Static.storage.getString(Keys.password);

  // ignore: public_member_api_docs
  String get grade => Static.storage.getString(Keys.grade);

  // ignore: public_member_api_docs
  int get group => Static.storage.getInt(Keys.group);

  // ignore: public_member_api_docs
  set username(String username) =>
      Static.storage.setString(Keys.username, username);

  // ignore: public_member_api_docs
  set password(String password) =>
      Static.storage.setString(Keys.password, password);

  // ignore: public_member_api_docs
  set grade(String grade) => Static.storage.setString(Keys.grade, grade);

  // ignore: public_member_api_docs
  set group(int group) => Static.storage.setInt(Keys.group, group);

  /// Resets all user data
  void clear() {
    username = null;
    password = null;
    grade = null;
    group = null;
  }
}
