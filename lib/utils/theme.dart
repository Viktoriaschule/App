import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

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
ThemeData get theme => ThemeData(
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
ThemeData get darkTheme => ThemeData(
      brightness: Brightness.dark,
      primaryColor: darkColor,
      accentColor: theme.accentColor,
      highlightColor: Color(0xFF666666),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: darkColor,
        contentTextStyle: TextStyle(
          color: lightColor,
        ),
      ),
      primaryIconTheme: IconThemeData(
        color: Color(0xFFCCCCCC),
      ),
      cardTheme: theme.cardTheme,
      cardColor: darkColor,
      backgroundColor: darkBackgroundColor,
      fontFamily: 'Ubuntu',
    );

/// TODO: Remove the usage of these functions by using the theme
/// Get the text color according to the theme
Color textColor(BuildContext context) =>
    MediaQuery.of(context).platformBrightness == Brightness.light
        ? darkColor
        : Color(0xFFCCCCCC);

/// Get the text color according to the theme
Color textColorLight(BuildContext context) =>
    MediaQuery.of(context).platformBrightness == Brightness.light
        ? darkColorLight
        : Color(0xFFCCCCCC);
