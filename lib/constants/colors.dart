import 'package:flutter/material.dart';

/// 하루성공 앱의 색상 테마
/// 밝고 산뜻한 파스텔 계열로 구성
class AppColors {
  // 메인 파스텔 색상들
  static const Color primaryMint = Color(0xFF98E4D6);        // 민트색
  static const Color primaryLavender = Color(0xFFCFB3FF);    // 라벤더색
  static const Color primaryYellow = Color(0xFFFFF3A0);      // 옐로우
  static const Color primaryPink = Color(0xFFFFB3D1);        // 핑크색
  
  // 배경색
  static const Color backgroundLight = Color(0xFFFAFAFA);    // 라이트 모드 배경
  static const Color backgroundDark = Color(0xFF121212);     // 다크 모드 배경
  
  // 텍스트 색상
  static const Color textPrimary = Color(0xFF2D3748);        // 주요 텍스트
  static const Color textSecondary = Color(0xFF718096);      // 보조 텍스트
  static const Color textLight = Color(0xFFFFFFFF);          // 밝은 텍스트
  
  // 기능별 색상
  static const Color success = Color(0xFF48BB78);            // 성공/달성
  static const Color accent = Color(0xFFED8936);             // 강조색
  static const Color cardBackground = Color(0xFFFFFFFF);     // 카드 배경
  static const Color divider = Color(0xFFE2E8F0);           // 구분선
  
  // 호환성을 위한 별칭들
  static const Color primary = primaryMint;
  static const Color secondary = primaryLavender;
  static const Color background = backgroundLight;
  
  // 그라데이션 색상들
  static const List<Color> mintGradient = [
    Color(0xFF98E4D6),
    Color(0xFFB8F2E6),
  ];
  
  static const List<Color> lavenderGradient = [
    Color(0xFFCFB3FF),
    Color(0xFFE0C8FF),
  ];
} 