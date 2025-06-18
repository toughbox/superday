import 'package:flutter/material.dart';

/// 하루성공 앱의 색상 테마 (Genesis Travel 여정 컨셉)
/// 목표 달성을 여행의 여정으로 표현하는 색상 시스템
class AppColors {
  // 메인 색상들 (여행/여정 테마)
  static const Color skyBlue = Color(0xFF1E88E5); // 하늘 블루 (여행의 시작)
  static const Color deepSky = Color(0xFF1565C0); // 깊은 하늘 (목표 집중)
  static const Color lightSky = Color(0xFF42A5F5); // 밝은 하늘 (희망)
  static const Color sunsetOrange = Color(0xFFFF9800); // 석양 오렌지 (달성의 기쁨)

  // 배경색 (구름과 하늘)
  static const Color backgroundLight = Color(0xFFF8FAFF); // 구름 같은 배경
  static const Color surfaceWhite = Color(0xFFFFFFFF); // 순백 구름
  static const Color surfaceCloud = Color(0xFFF5F7FA); // 연한 구름색

  // 텍스트 색상
  static const Color textPrimary = Color(0xFF000000); // 검은색 텍스트 (백그라운드가 흰색일 때)
  static const Color textSecondary = Color(0xFF424242); // 회색 텍스트
  static const Color textLight = Color(0xFFFFFFFF); // 밝은 텍스트
  static const Color textMuted = Color(0xFF78909C); // 연한 텍스트

  // 기능별 색상 (여행 테마)
  static const Color success = Color(0xFF4CAF50); // 목적지 도착 (녹색)
  static const Color warning = Color(0xFFFF9800); // 주의 (오렌지)
  static const Color error = Color(0xFFF44336); // 위험 (빨강)
  static const Color info = Color(0xFF2196F3); // 정보 (파랑)

  // 여행 관련 특별 색상
  static const Color journeyStart = Color(0xFF81C784); // 여행 시작 (연두)
  static const Color journeyProgress = Color(0xFF64B5F6); // 여행 중 (하늘)
  static const Color journeyComplete = Color(0xFFFFB74D); // 여행 완료 (금색)

  // UI 요소
  static const Color cardBackground = Color(0xFFFFFFFF); // 카드 배경
  static const Color divider = Color(0xFFE0E0E0); // 구분선
  static const Color border = Color(0xFFBDBDBD); // 테두리
  static const Color shadow = Color(0x1A1565C0); // 그림자 (하늘색 톤)

  // 호환성을 위한 별칭들
  static const Color primary = skyBlue;
  static const Color secondary = sunsetOrange;
  static const Color background = backgroundLight;
  static const Color accent = sunsetOrange;

  // 기존 파스텔 색상들 호환용
  static const Color primaryMint = lightSky; // 민트 → 밝은 하늘
  static const Color primaryLavender = Color(0xFF9C27B0); // 라벤더 → 자주색
  static const Color primaryYellow = sunsetOrange; // 옐로우 → 석양
  static const Color primaryPink = Color(0xFFE91E63); // 핑크 → 분홍

  // 그라데이션 색상들 (하늘과 구름)
  static const List<Color> skyGradient = [Color(0xFF1E88E5), Color(0xFF42A5F5)];

  static const List<Color> sunsetGradient = [
    Color(0xFFFF9800),
    Color(0xFFFFB74D),
  ];

  static const List<Color> journeyGradient = [
    Color(0xFF81C784),
    Color(0xFF64B5F6),
    Color(0xFFFFB74D),
  ];

  // 기존 호환성을 위한 그라데이션
  static const List<Color> mintGradient = skyGradient;
  static const List<Color> lavenderGradient = [
    Color(0xFF9C27B0),
    Color(0xFFBA68C8),
  ];
}
