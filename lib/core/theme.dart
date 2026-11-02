import 'package:flutter/material.dart';

abstract final class BalbColors {
  static const background = Color(0xff191919),
      surface = Color(0xff222323),
      primary = Color(0xff1dbdc6),
      secondary = Color(0xffff7b80),
      muted = Color(0xffb2b4b5),
      line = Color(0xff303234);
}

ThemeData balbTheme() => ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: BalbColors.background,
  colorScheme: const ColorScheme.dark(
    primary: BalbColors.primary,
    secondary: BalbColors.secondary,
    surface: BalbColors.surface,
  ),
  fontFamily: 'Jakarta',
  textTheme: const TextTheme(
    headlineLarge: TextStyle(
      fontFamily: 'Poppins',
      fontWeight: FontWeight.w600,
      fontSize: 40,
      height: 1.22,
    ),
    headlineMedium: TextStyle(
      fontFamily: 'Poppins',
      fontWeight: FontWeight.w600,
      fontSize: 32,
      height: 1.25,
    ),
    headlineSmall: TextStyle(
      fontFamily: 'Poppins',
      fontWeight: FontWeight.w600,
      fontSize: 24,
      height: 1.35,
    ),
    titleLarge: TextStyle(
      fontFamily: 'Poppins',
      fontWeight: FontWeight.w600,
      fontSize: 18,
    ),
    titleMedium: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
    bodyLarge: TextStyle(fontSize: 14, height: 1.6),
    bodyMedium: TextStyle(fontSize: 13, height: 1.5),
    bodySmall: TextStyle(fontSize: 11, color: BalbColors.muted),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.transparent,
    surfaceTintColor: Colors.transparent,
    centerTitle: true,
    elevation: 0,
    titleTextStyle: TextStyle(
      fontFamily: 'Poppins',
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: Colors.white,
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: BalbColors.surface,
    contentPadding: const EdgeInsets.all(18),
    hintStyle: const TextStyle(color: Color(0xff717575), fontSize: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(7),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(7),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(7),
      borderSide: const BorderSide(color: BalbColors.primary),
    ),
  ),
  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      backgroundColor: BalbColors.primary,
      foregroundColor: Colors.white,
      minimumSize: const Size.fromHeight(48),
      textStyle: const TextStyle(
        fontFamily: 'Jakarta',
        fontWeight: FontWeight.w700,
        fontSize: 14,
      ),
    ),
  ),
  dividerTheme: const DividerThemeData(color: BalbColors.line, thickness: 1),
  snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
);
