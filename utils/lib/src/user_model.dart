import 'keys.dart';
import 'static.dart';

/// User class
/// describes a user
class User {
  // ignore: public_member_api_docs
  User();

  // ignore: public_member_api_docs
  String get username => Static.storage.getString(Keys.username);

  // ignore: public_member_api_docs
  String get password => Static.storage.getString(Keys.password);

  /// The group is the grade for students and the teacher name for teachers
  String get group => Static.storage.getString(Keys.group);

  /// The user type is 1 (student), 2 (teacher), 4 (developer),  8 (other)
  /// or a combination of them
  int get _userType => Static.storage.getInt(Keys.userType);

  /// If the user is a teacher
  bool isTeacher() => [2, 3, 6, 10].contains(_userType);

  /// If the user is a teacher
  bool isDeveloper() => [4, 5, 6, 12].contains(_userType);

  // ignore: public_member_api_docs
  set username(String username) =>
      Static.storage.setString(Keys.username, username);

  // ignore: public_member_api_docs
  set password(String password) =>
      Static.storage.setString(Keys.password, password);

  // ignore: public_member_api_docs
  set group(String group) => Static.storage.setString(Keys.group, group);

  /// The user type is 1 (student), 2 (teacher), 4 (developer),  8 (other)
  /// or a combination of them
  // ignore: avoid_setters_without_getters
  set userType(int group) => Static.storage.setInt(Keys.userType, group);

  /// Resets all user data
  void clear() {
    username = null;
    password = null;
    group = null;
    userType = null;
  }
}
