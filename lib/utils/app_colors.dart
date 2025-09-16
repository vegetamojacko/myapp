import 'package:flutter/material.dart';

class AppColors {
  // Palette from the new logo
  static const Color primaryColor = Color(0xFF00838F); // Teal from logo
  static const Color accentColor = Color(0xFFF57C00); // Orange from logo

  // Light Theme
  static const Color lightBackground = Color(0xFFF5F5F5);
  static const Color lightPrimaryText = Color(0xFF212121);
  static const Color lightCard = Colors.white;

  // Dark Theme
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkPrimaryText = Colors.white;
  static const Color darkCard = Color(0xFF212121);

  // Semantic Colors (retained for status indicators)
  static const Color pendingBackground = Color(0xFFFFFDE7);
  static const Color pendingText = Color(0xFF8D6E63);
  static const Color completedBackground = Color(0xFFE8F5E9);
  static const Color completedText = Color(0xFF2E7D32);
  static const Color failedBackground = Color(0xFFFFEBEE);
  static const Color failedText = Color(0xFFC62828);

  // Deprecated colors - to be removed in a future update
  static const Color background = lightBackground;
  static const Color contentCard = lightCard;
  static const Color primaryText = lightPrimaryText;
  static const Color darkGradientStart = darkBackground;
  static const Color darkGradientEnd = darkBackground;
  static const Color primaryActionStart = primaryColor;
  static const Color primaryActionEnd = accentColor;
}
