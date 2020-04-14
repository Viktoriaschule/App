import 'package:utils/src/screen_sizes.dart';

// ignore: public_member_api_docs
class InfoCardUtils {
  /// Get the number of items to display
  static int cut(ScreenSize screenSize, int maximum) =>
      screenSize == ScreenSize.small ? 3 : maximum;
}
