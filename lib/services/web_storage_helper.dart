import 'dart:convert';
import 'dart:html' as html;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/goal.dart';
import '../models/achievement.dart';

/// 웹 환경용 데이터 저장소 헬퍼
class WebStorageHelper {
  static const String _goalsKey = 'goals';
  static const String _achievementsKey = 'achievements';

  /// 목표 저장
  Future<void> saveGoals(List<Goal> goals) async {
    final goalsJson = goals.map((goal) => goal.toJson()).toList();
    final jsonString = jsonEncode(goalsJson);

    // 웹에서는 localStorage 직접 사용
    if (kIsWeb) {
      html.window.localStorage[_goalsKey] = jsonString;
    } else {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_goalsKey, jsonString);
    }

    // 디버깅용 로그
    if (kDebugMode) {
      print('목표 저장됨: ${goals.length}개');
      print('저장된 데이터: $jsonString');
      if (kIsWeb) {
        print('localStorage에 저장됨');
      }
    }
  }

  /// 목표 로드
  Future<List<Goal>> loadGoals() async {
    String? goalsString;

    // 웹에서는 localStorage 직접 사용
    if (kIsWeb) {
      goalsString = html.window.localStorage[_goalsKey];
    } else {
      final prefs = await SharedPreferences.getInstance();
      goalsString = prefs.getString(_goalsKey);
    }

    // 디버깅용 로그
    if (kDebugMode) {
      print('목표 로드 시도...');
      print('저장된 데이터: $goalsString');
      if (kIsWeb) {
        print('localStorage에서 로드');
      }
    }

    if (goalsString == null || goalsString.isEmpty) {
      if (kDebugMode) {
        print('저장된 목표 없음');
      }
      return [];
    }

    try {
      final goalsJson = jsonDecode(goalsString) as List;
      final goals = goalsJson.map((json) => Goal.fromJson(json)).toList();

      if (kDebugMode) {
        print('목표 로드됨: ${goals.length}개');
      }

      return goals;
    } catch (e) {
      if (kDebugMode) {
        print('목표 로드 오류: $e');
      }
      return [];
    }
  }

  /// 달성 기록 저장
  Future<void> saveAchievements(List<Achievement> achievements) async {
    final achievementsJson =
        achievements.map((achievement) => achievement.toJson()).toList();
    final jsonString = jsonEncode(achievementsJson);

    // 웹에서는 localStorage 직접 사용
    if (kIsWeb) {
      html.window.localStorage[_achievementsKey] = jsonString;
    } else {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_achievementsKey, jsonString);
    }

    // 디버깅용 로그
    if (kDebugMode) {
      print('달성기록 저장됨: ${achievements.length}개');
    }
  }

  /// 달성 기록 로드
  Future<List<Achievement>> loadAchievements() async {
    String? achievementsString;

    // 웹에서는 localStorage 직접 사용
    if (kIsWeb) {
      achievementsString = html.window.localStorage[_achievementsKey];
    } else {
      final prefs = await SharedPreferences.getInstance();
      achievementsString = prefs.getString(_achievementsKey);
    }

    if (achievementsString == null || achievementsString.isEmpty) return [];

    try {
      final achievementsJson = jsonDecode(achievementsString) as List;
      return achievementsJson
          .map((json) => Achievement.fromJson(json))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('달성기록 로드 오류: $e');
      }
      return [];
    }
  }

  /// 모든 데이터 삭제
  Future<void> clearAll() async {
    // 웹에서는 localStorage 직접 사용
    if (kIsWeb) {
      html.window.localStorage.remove(_goalsKey);
      html.window.localStorage.remove(_achievementsKey);
    } else {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_goalsKey);
      await prefs.remove(_achievementsKey);
    }
  }
}
