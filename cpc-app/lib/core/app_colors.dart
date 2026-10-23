import 'package:flutter/material.dart';

class AppColors {
  static const navy = Color(0xFF0B3A63);
  static const sky = Color(0xFF14B8D4);
  static const orange = Color(0xFFF59E0B);
  static const green = Color(0xFF22C55E);
  static const red = Color(0xFFEF4444);
  static const lightBg = Color(0xFFF8FAFC);

  static Color statusColor(String status) {
    switch (status) {
      case 'OVERDUE':
        return red;
      case 'DUE_SOON':
        return orange;
      case 'ACTIVE':
        return sky;
      case 'COMPLETED':
        return green;
      case 'PARKED':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }
}