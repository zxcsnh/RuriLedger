import 'package:flutter/material.dart';
import 'package:myapp/src/utils/appColors.dart';

class AppTheme {
  static ThemeData get lightTheme => ThemeData(
    primarySwatch: Colors.blue,
    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      elevation: 8,
      selectedItemColor: AppColors.iconSelected,
      unselectedItemColor: AppColors.iconUnselected,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      backgroundColor: AppColors.background,
    ),
  );
}