import 'package:flutter/material.dart';

/// HeroUI 스타일의 현대적 색상 시스템
class AppColors {
  // Primary Colors (HeroUI 블루)
  static const Color primary = Color(0xFF006FEE);
  static const Color primaryLight = Color(0xFF338EF7);
  static const Color primaryDark = Color(0xFF005BC4);

  // Secondary Colors
  static const Color secondary = Color(0xFF9353D3);
  static const Color secondaryLight = Color(0xFFA855F7);

  // Surface Colors (Glass Effect)
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF4F4F5);
  static const Color surfaceContainer = Color(0xFFFAFAFA);
  static const Color surfaceCloud = Color(0xFFF7F7F7);

  // Background Gradients
  static const List<Color> backgroundGradient = [
    Color(0xFFF8FAFC),
    Color(0xFFE2E8F0),
  ];

  static const List<Color> primaryGradient = [
    Color(0xFF006FEE),
    Color(0xFF338EF7),
  ];

  static const List<Color> successGradient = [
    Color(0xFF17C964),
    Color(0xFF45D483),
  ];

  static const List<Color> skyGradient = [Color(0xFF87CEEB), Color(0xFFE0F6FF)];

  // Status Colors
  static const Color success = Color(0xFF17C964);
  static const Color successLight = Color(0xFF45D483);
  static const Color warning = Color(0xFFF5A524);
  static const Color danger = Color(0xFFF31260);
  static const Color dangerLight = Color(0xFFFF6B9D);

  // Text Colors
  static const Color textPrimary = Color(0xFF11181C);
  static const Color textSecondary = Color(0xFF687076);
  static const Color textTertiary = Color(0xFF9CA3AF);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textMuted = Color(0xFF9CA3AF);
  static const Color textLight = Color(0xFFFFFFFF);

  // Border Colors
  static const Color border = Color(0xFFE4E4E7);
  static const Color borderLight = Color(0xFFF4F4F5);
  static const Color divider = Color(0xFFE4E4E7);

  // Shadow Colors
  static const Color shadow = Color(0x1A000000);
  static const Color shadowMedium = Color(0x33000000);

  // Glass Effect Colors
  static const Color glass = Color(0x80FFFFFF);
  static const Color glassStrong = Color(0xCCFFFFFF);

  // Journey/Progress Colors
  static const Color journeyStart = Color(0xFF006FEE);
  static const Color journeyProgress = Color(0xFF17C964);
  static const Color journeyComplete = Color(0xFFFF6B9D);

  // Additional Colors
  static const Color skyBlue = Color(0xFF87CEEB);
  static const Color lightSky = Color(0xFFE0F6FF);
  static const Color sunsetOrange = Color(0xFFF5A524);
  static const Color primaryPink = Color(0xFFF31260);

  // 기존 호환성을 위한 별칭들
  static const Color background = Color(0xFFF8FAFC);
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color primaryMint = Color(0xFF17C964);
  static const Color primaryLavender = Color(0xFF006FEE);
}
