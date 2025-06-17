import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/goal.dart';
import '../models/achievement.dart';

/// 웹 환경용 데이터 저장소 헬퍼
class WebStorageHelper {
  static const String _goalsKey = 'goals';
  static const String _achievementsKey = 'achievements';

  /// 목표 저장
  Future<void> saveGoals(List<Goal> goals) async {
    final prefs = await SharedPreferences.getInstance();
    final goalsJson = goals.map((goal) => goal.toJson()).toList();
    await prefs.setString(_goalsKey, jsonEncode(goalsJson));
  }

  /// 목표 로드
  Future<List<Goal>> loadGoals() async {
    final prefs = await SharedPreferences.getInstance();
    final goalsString = prefs.getString(_goalsKey);
    
    if (goalsString == null) return [];
    
    final goalsJson = jsonDecode(goalsString) as List;
    return goalsJson.map((json) => Goal.fromJson(json)).toList();
  }

  /// 달성 기록 저장
  Future<void> saveAchievements(List<Achievement> achievements) async {
    final prefs = await SharedPreferences.getInstance();
    final achievementsJson = achievements.map((achievement) => achievement.toJson()).toList();
    await prefs.setString(_achievementsKey, jsonEncode(achievementsJson));
  }

  /// 달성 기록 로드
  Future<List<Achievement>> loadAchievements() async {
    final prefs = await SharedPreferences.getInstance();
    final achievementsString = prefs.getString(_achievementsKey);
    
    if (achievementsString == null) return [];
    
    final achievementsJson = jsonDecode(achievementsString) as List;
    return achievementsJson.map((json) => Achievement.fromJson(json)).toList();
  }

  /// 모든 데이터 삭제
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_goalsKey);
    await prefs.remove(_achievementsKey);
  }
} 