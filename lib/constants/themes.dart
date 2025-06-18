import 'package:flutter/material.dart';
import 'colors.dart';

/// 하루성공 앱의 테마 설정 (Genesis Travel 여정 컨셉)
/// 목표 달성을 여행의 여정으로 표현하는 디자인
class AppThemes {
  // 여행 테마 (Genesis 스타일)
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      // 색상 스키마 (여행 테마)
      colorScheme: ColorScheme.light(
        primary: AppColors.skyBlue,
        secondary: AppColors.sunsetOrange,
        surface: AppColors.surfaceWhite,
        background: AppColors.backgroundLight,
        onPrimary: AppColors.textLight,
        onSecondary: AppColors.textLight,
        onSurface: AppColors.textPrimary,
        onBackground: AppColors.textPrimary,
        error: AppColors.error,
        onError: AppColors.textLight,
      ),

      // 앱바 테마 (하늘 같은 디자인)
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.skyBlue,
        foregroundColor: AppColors.textLight,
        elevation: 0,
        shadowColor: AppColors.shadow,
        centerTitle: true,
        titleTextStyle: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: AppColors.textLight,
          letterSpacing: 0.5,
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),

      // 카드 테마 (구름 같은 부드러운 느낌)
      cardTheme: CardThemeData(
        color: AppColors.cardBackground,
        elevation: 6,
        shadowColor: AppColors.shadow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: AppColors.divider.withOpacity(0.3),
            width: 0.5,
          ),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),

      // 버튼 테마 (여행 출발 느낌)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.skyBlue,
          foregroundColor: AppColors.textLight,
          elevation: 4,
          shadowColor: AppColors.shadow,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8,
          ),
        ),
      ),

      // 아웃라인 버튼 (여행 계획)
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.skyBlue,
          side: BorderSide(color: AppColors.skyBlue, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
        ),
      ),

      // 플로팅 액션 버튼 (목적지 추가)
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.sunsetOrange,
        foregroundColor: AppColors.textLight,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),

      // 입력 필드 테마 (여행 검색 느낌)
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.border, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.border, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.skyBlue, width: 2.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.error, width: 1.5),
        ),
        fillColor: AppColors.surfaceCloud,
        filled: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
        hintStyle: TextStyle(
          color: AppColors.textMuted,
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
      ),

      // 텍스트 테마 (여행 가이드북 스타일)
      textTheme: const TextTheme(
        // 헤드라인 (목적지 제목)
        headlineLarge: TextStyle(
          fontSize: 34,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
          letterSpacing: -0.8,
          height: 1.1,
        ),
        headlineMedium: TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
          letterSpacing: -0.3,
          height: 1.2,
        ),
        headlineSmall: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
          letterSpacing: 0,
          height: 1.3,
        ),

        // 바디 텍스트 (여행 설명)
        bodyLarge: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w400,
          color: AppColors.textPrimary,
          height: 1.6,
          letterSpacing: 0.1,
        ),
        bodyMedium: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: AppColors.textPrimary,
          height: 1.5,
          letterSpacing: 0.1,
        ),
        bodySmall: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: AppColors.textMuted,
          height: 1.4,
          letterSpacing: 0.2,
        ),

        // 라벨 (여행 태그)
        labelLarge: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
          letterSpacing: 0.5,
        ),
        labelMedium: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
          letterSpacing: 0.8,
        ),
      ),

      // 구분선 테마
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
        space: 1,
      ),

      // 스위치 테마 (여행 모드 전환)
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return AppColors.sunsetOrange;
          }
          return AppColors.textMuted;
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return AppColors.sunsetOrange.withOpacity(0.4);
          }
          return AppColors.divider;
        }),
      ),

      // 체크박스 테마 (체크리스트)
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return AppColors.journeyComplete;
          }
          return Colors.transparent;
        }),
        checkColor: MaterialStateProperty.all(AppColors.textLight),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),

      // 진행 표시기 테마 (여행 진행도)
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.journeyProgress,
        linearTrackColor: AppColors.divider,
      ),

      // 칩 테마 (여행 태그)
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceCloud,
        deleteIconColor: AppColors.textMuted,
        disabledColor: AppColors.divider,
        selectedColor: AppColors.lightSky.withOpacity(0.2),
        secondarySelectedColor: AppColors.sunsetOrange.withOpacity(0.2),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        labelStyle: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        secondaryLabelStyle: const TextStyle(
          color: AppColors.textLight,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        brightness: Brightness.light,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  // 다크 테마 제거됨 (라이트 테마만 사용)
}
