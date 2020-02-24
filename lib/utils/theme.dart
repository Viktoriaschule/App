import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:viktoriaapp/models/models.dart';
import 'package:viktoriaapp/utils/static.dart';

// ignore: public_member_api_docs
final Color lightColor = Color(0xFFFAFAFA);
// ignore: public_member_api_docs
final Color lightBackgroundColor = lightColor;
// ignore: public_member_api_docs
final Color darkColor = Color(0xFF424242);
// ignore: public_member_api_docs
final Color darkColorLight = Color(0x90000000);
// ignore: public_member_api_docs
final Color darkBackgroundColor = Color(0xFF303030);

final _accentColor = Color(0xFF74B451);

/// Get the theme of the app
ThemeData get _theme => ThemeData(
      brightness: Brightness.light,
      primaryColor: lightColor,
      accentColor: _accentColor,
      primaryIconTheme: IconThemeData(
        color: darkColor,
      ),
      cardTheme: CardTheme(
        elevation: 5,
      ),
      cardColor: lightColor,
      backgroundColor: lightBackgroundColor,
      fontFamily: 'Ubuntu',
    );

/// Get the dark theme of the app
ThemeData get _darkTheme => ThemeData(
      brightness: Brightness.dark,
      primaryColor: darkColor,
      accentColor: _theme.accentColor,
      highlightColor: Color(0xFF666666),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: Color.lerp(darkColor, darkBackgroundColor, 0.5),
        actionTextColor: _theme.accentColor,
        contentTextStyle: TextStyle(
          color: lightColor,
        ),
      ),
      primaryIconTheme: IconThemeData(
        color: Color(0xFFCCCCCC),
      ),
      cardTheme: _theme.cardTheme,
      cardColor: darkColor,
      backgroundColor: darkBackgroundColor,
      fontFamily: 'Ubuntu',
    );

// ignore: public_member_api_docs
class ThemeWidget extends InheritedWidget {
  // ignore: public_member_api_docs
  const ThemeWidget({@required Widget child}) : super(child: child);

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => false;

  /// Find the closest [ThemeWidget] from ancestor tree.
  static ThemeWidget of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<ThemeWidget>();

  // ignore: public_member_api_docs
  ThemeData get theme => brightness == Brightness.light ? _theme : _darkTheme;

  /// Returns the current layout brightness
  Brightness get brightness {
    if (Static.storage.getBool(Keys.automaticDesign) ?? true) {
      return Static.storage.getBool(Keys.platformBrightness) ?? false
          ? Brightness.dark
          : Brightness.light;
    }
    if (Static.storage.getBool(Keys.darkMode) ?? false) {
      return Brightness.dark;
    }
    return Brightness.light;
  }

  /// TODO: Remove the usage of these functions by using the theme
  /// Get the text color according to the theme
  Color get textColor =>
      brightness == Brightness.light ? darkColor : Color(0xFFCCCCCC);

  /// Get the text color according to the theme
  Color get textColorLight =>
      brightness == Brightness.light ? darkColorLight : Color(0xFFCCCCCC);
}
