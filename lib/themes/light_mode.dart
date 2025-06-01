import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData lightMode = ThemeData(
    useMaterial3: true,
    primaryColor: Color(0xFF6F8BBD),
    textTheme: GoogleFonts.josefinSansTextTheme(),
    dividerColor: Colors.white,
    colorScheme: ColorScheme.light(
        surface: Color(0xFFF9F9F9),
        primary: Color(0xFF6F8BBD),
        secondary: Color(0xFFD0E4FF),
        tertiary: Color(0xFF142553),
    )
);