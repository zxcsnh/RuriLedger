import 'package:flutter/material.dart';

class AppColors {
  // Primary colors
  static const Color primary = Colors.blue;
  static const Color primaryDark = Color(0xFF1976D2);
  static const Color primaryLight = Color(0xFFBBDEFB);

  // Background colors
  static const Color background = Colors.white;
  static const Color bottomNavBarBackground = Color(0xFFE3F2FD); // blue[50]
  static const Color appBarBackground = Color(0xFFE3F2FD); // blue[50]
  static const Color pageBackground = Color(0xFFF5F5F5); // grey[100]
  static const Color cardBackground = Color(0xFFE3F2FD); // blue[50]
  static const Color expandedCardBackground = Color(0xFFE8F5E9); // green[50]
  static const Color inputCardBackground = Color(0xFFE8F5E9); // green[50]
  static const Color categoryCardBackground = Colors.white;
  static const Color dialogBackground = Colors.white;

  // Text colors
  static const Color textPrimary = Colors.black87;
  static const Color textSecondary = Colors.grey;
  static const Color textHint = Color(0xFF9E9E9E); // grey[500]
  static const Color textDark = Colors.black87;
  static const Color textLight = Colors.white;

  // Button colors
  static const Color buttonPrimary = Colors.blue;
  static const Color buttonSecondary = Colors.grey;
  static const Color buttonDanger = Colors.red;
  static const Color buttonTabActive = Colors.blue;
  static const Color buttonTabInactive = Colors.grey;

  // Icon colors
  static const Color iconSelected = Colors.blue;
  static const Color iconUnselected = Colors.grey;
  static const Color iconIncome = Colors.green;
  static const Color iconExpense = Colors.red;
  static const Color iconCalendar = Colors.blue;
  static const Color iconSave = Colors.white;

  // Shadow colors
  static const Color shadow = Colors.grey;
  static const Color lightShadow = Color(0x1A000000); // black with 10% opacity

  // Border colors
  static const Color border = Color(0xFF90CAF9); // blue[200]
  static const Color borderLight = Color(0xFFE0E0E0); // grey[200]
  static const Color borderSelected = Colors.blue;
  static const Color borderUnselected = Color(0xFFE0E0E0); // grey[200]

  // Divider colors
  static const Color divider = Color(0xFFE0E0E0); // grey[200]

  // Floating Action Button colors
  static const Color fabBackground = Colors.white;
  static const Color fabIcon = Colors.blue;

  // Transaction type colors
  static const Color income = Colors.green;
  static const Color expense = Colors.red;
  static const Color balancePositive = Colors.blue;
  static const Color balanceNegative = Colors.orange;

  // Progress indicator colors
  static const Color progressBackground = Color(0xFFFFCDD2); // red[200]
  static const Color progressValue = Color(0xFFA5D6A7); // green[400]

  // Card state colors
  static const Color cardSelected = Color(0xFFE3F2FD); // blue[50]
  static const Color cardUnselected = Colors.white;
}