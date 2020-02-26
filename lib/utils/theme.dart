import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_event_bus/flutter_event_bus.dart';
import 'package:viktoriaapp/models/models.dart';
import 'package:viktoriaapp/plugins/platform/platform.dart';
import 'package:viktoriaapp/utils/events.dart';
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
        elevation: Platform().isWeb ? 2 : 5,
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
    if (!Static.storage.has(Keys.automaticDesign) ||
            Static.storage.getBool(Keys.automaticDesign) ??
        true) {
      return Static.storage.has(Keys.platformBrightness) &&
                  Static.storage.getBool(Keys.platformBrightness) ??
              false
          ? Brightness.dark
          : Brightness.light;
    }
    if (Static.storage.has(Keys.darkMode) &&
            Static.storage.getBool(Keys.darkMode) ??
        false) {
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

// ignore: public_member_api_docs
class ThemeUpdateWidget extends StatefulWidget {
  // ignore: public_member_api_docs
  const ThemeUpdateWidget({
    Key key,
    this.child,
  }) : super(key: key);

  // ignore: public_member_api_docs
  final Widget child;

  @override
  _ThemeUpdateWidgetState createState() => _ThemeUpdateWidgetState();
}

class _ThemeUpdateWidgetState extends Interactor<ThemeUpdateWidget> {
  @override
  Widget build(BuildContext context) => widget.child;

  @override
  void didChangeDependencies() {
    _update();
    super.didChangeDependencies();
  }

  @override
  Subscription subscribeEvents(EventBus eventBus) =>
      eventBus.respond<ThemeChangedEvent>((event) => _update());

  void _update() {
    if (!Static.storage.has(Keys.platformBrightness) ||
        Static.storage.getBool(Keys.platformBrightness) !=
            (MediaQuery.of(context).platformBrightness == Brightness.dark)) {
      Static.storage.setBool(Keys.platformBrightness,
          MediaQuery.of(context).platformBrightness == Brightness.dark);
      EventBus.of(context).publish(ThemeChangedEvent());
    }
  }
}
