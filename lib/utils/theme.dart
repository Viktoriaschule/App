import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Get the theme of the app
ThemeData get theme => ThemeData(
      brightness: Brightness.light,
      primaryColor: Color(0xFFFAFAFA),
      accentColor: Color(0xFF74B451),
      textTheme: GoogleFonts.ubuntuTextTheme(),
      accentTextTheme: GoogleFonts.ubuntuTextTheme(),
      primaryTextTheme: GoogleFonts.ubuntuTextTheme(),
    );
