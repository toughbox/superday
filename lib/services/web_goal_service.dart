import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/goal.dart';
import '../models/achievement.dart';
import '../constants/strings.dart';
import 'web_storage_helper.dart';

/// 웹 환경용 목표 관리 서비스
class WebGoalService {
  final WebStorageHelper _storage = WebStorageHelper();

  List<Goal> _goals = [];
  List<Achievement> _achievements = [];

  /// 고유 ID 생성
  String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  /// 랜덤 축하 메시지 선택
  String _getRandomCelebrationMessage() {
    final random = Random();
    return AppStrings.celebrationMessages[random.nextInt(
      AppStrings.celebrationMessages.length,
    )];
  }

  /// 데이터 초기화
  Future<void> initialize() async {
    try {
      _goals = await _storage.loadGoals();
      _achievements = await _storage.loadAchievements();

      // 디버깅용 로그
      if (kDebugMode) {
        print('WebGoalService 초기화 완료:');
        print('- 로드된 목표 수: ${_goals.length}');
        print('- 로드된 달성기록 수: ${_achievements.length}');
        if (_goals.isNotEmpty) {
          print('- 목표 목록: ${_goals.map((g) => g.title).join(', ')}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('WebGoalService 초기화 오류: $e');
      }
      _goals = [];
      _achievements = [];
    }
  }

  /// 새 목표 추가
  Future<Goal> addGoal(String title) async {
    // 입력 검증
    if (title.trim().isEmpty) {
      throw Exception(AppStrings.goalEmpty);
    }

    if (title.length > 50) {
      throw Exception(AppStrings.goalTooLong);
    }

    // 오늘 같은 목표가 있는지 확인
    final todayGoals = await getTodayGoals();
    final duplicateGoal =
        todayGoals
            .where(
              (goal) => goal.title.toLowerCase() == title.trim().toLowerCase(),
            )
            .firstOrNull;

    if (duplicateGoal != null) {
      throw Exception(AppStrings.goalAlreadyExists);
    }

    // 새 목표 생성
    final goal = Goal(
      id: _generateId(),
      title: title.trim(),
      createdDate: DateTime.now(),
    );

    _goals.insert(0, goal);
    await _storage.saveGoals(_goals);

    // 디버깅용 로그
    if (kDebugMode) {
      print('목표 추가됨: ${goal.title}');
      print('현재 총 목표 수: ${_goals.length}');
    }

    return goal;
  }

  /// 목표 완료 처리
  Future<Achievement> completeGoal(String goalId) async {
    // 목표 조회
    final goalIndex = _goals.indexWhere((g) => g.id == goalId);

    if (goalIndex == -1) {
      throw Exception('목표를 찾을 수 없습니다.');
    }

    final goal = _goals[goalIndex];

    if (goal.isCompleted) {
      throw Exception('이미 완료된 목표입니다.');
    }

    // 목표 완료 처리
    final completedGoal = goal.copyWithCompleted();
    _goals[goalIndex] = completedGoal;
    await _storage.saveGoals(_goals);

    // 달성 기록 생성
    final achievement = Achievement(
      id: _generateId(),
      goalId: goalId,
      achievedDate: DateTime.now(),
      celebrationMessage: _getRandomCelebrationMessage(),
    );

    _achievements.insert(0, achievement);
    await _storage.saveAchievements(_achievements);
    return achievement;
  }

  /// 목표 삭제
  Future<void> deleteGoal(String goalId) async {
    _goals.removeWhere((goal) => goal.id == goalId);
    await _storage.saveGoals(_goals);
  }

  /// 목표 수정
  Future<Goal> updateGoal(String goalId, String newTitle) async {
    if (newTitle.trim().isEmpty) {
      throw Exception(AppStrings.goalEmpty);
    }

    if (newTitle.length > 50) {
      throw Exception(AppStrings.goalTooLong);
    }

    final goalIndex = _goals.indexWhere((g) => g.id == goalId);

    if (goalIndex == -1) {
      throw Exception('목표를 찾을 수 없습니다.');
    }

    final updatedGoal = _goals[goalIndex].copyWith(title: newTitle.trim());
    _goals[goalIndex] = updatedGoal;
    await _storage.saveGoals(_goals);
    return updatedGoal;
  }

  /// 오늘의 목표 조회
  Future<List<Goal>> getTodayGoals() async {
    final today = DateTime.now();
    return getGoalsByDate(today);
  }

  /// 모든 목표 조회
  Future<List<Goal>> getAllGoals() async {
    return List.from(_goals);
  }

  /// 특정 날짜의 목표 조회
  Future<List<Goal>> getGoalsByDate(DateTime date) async {
    final dateKey = DateTime(date.year, date.month, date.day);
    return _goals.where((goal) {
      final goalDate = DateTime(
        goal.createdDate.year,
        goal.createdDate.month,
        goal.createdDate.day,
      );
      return goalDate == dateKey;
    }).toList();
  }

  /// 날짜 범위로 목표 조회
  Future<List<Goal>> getGoalsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    return _goals.where((goal) {
      final goalDate = DateTime(
        goal.createdDate.year,
        goal.createdDate.month,
        goal.createdDate.day,
      );
      final start = DateTime(startDate.year, startDate.month, startDate.day);
      final end = DateTime(endDate.year, endDate.month, endDate.day);

      return goalDate.isAfter(start.subtract(const Duration(days: 1))) &&
          goalDate.isBefore(end.add(const Duration(days: 1)));
    }).toList();
  }

  /// 월별 목표 조회 (달력용)
  Future<Map<DateTime, List<Goal>>> getMonthlyGoals(DateTime month) async {
    final startOfMonth = DateTime(month.year, month.month, 1);
    final endOfMonth = DateTime(month.year, month.month + 1, 0);

    final goals = await getGoalsByDateRange(startOfMonth, endOfMonth);

    final Map<DateTime, List<Goal>> monthlyGoals = {};

    for (final goal in goals) {
      final date = DateTime(
        goal.createdDate.year,
        goal.createdDate.month,
        goal.createdDate.day,
      );

      if (monthlyGoals[date] == null) {
        monthlyGoals[date] = [];
      }
      monthlyGoals[date]!.add(goal);
    }

    return monthlyGoals;
  }

  /// 최근 N일간의 목표 조회
  Future<List<Goal>> getRecentGoals(int days) async {
    final endDate = DateTime.now();
    final startDate = endDate.subtract(Duration(days: days - 1));
    return await getGoalsByDateRange(startDate, endDate);
  }

  /// 달성률 계산
  Future<double> getAchievementRate({int? days}) async {
    List<Goal> goals;

    if (days != null) {
      goals = await getRecentGoals(days);
    } else {
      goals = await getAllGoals();
    }

    if (goals.isEmpty) return 0.0;

    final completedCount = goals.where((goal) => goal.isCompleted).length;
    return completedCount / goals.length;
  }

  /// 연속 달성 일수 계산
  Future<int> getStreakDays() async {
    final goals = await getAllGoals();

    // 날짜별로 그룹화
    final Map<String, List<Goal>> goalsByDate = {};
    for (final goal in goals) {
      final dateKey = goal.createdDate.toIso8601String().substring(0, 10);
      if (goalsByDate[dateKey] == null) {
        goalsByDate[dateKey] = [];
      }
      goalsByDate[dateKey]!.add(goal);
    }

    // 오늘부터 역순으로 연속 달성 일수 계산
    int streakDays = 0;
    final today = DateTime.now();

    for (int i = 0; i < 365; i++) {
      // 최대 1년까지 확인
      final checkDate = today.subtract(Duration(days: i));
      final dateKey = checkDate.toIso8601String().substring(0, 10);

      final dayGoals = goalsByDate[dateKey] ?? [];

      // 그날 목표가 없으면 연속 끊김
      if (dayGoals.isEmpty) {
        if (i == 0) continue; // 오늘 목표가 없어도 계속
        break;
      }

      // 그날 모든 목표가 완료되었는지 확인
      final allCompleted = dayGoals.every((goal) => goal.isCompleted);
      if (allCompleted) {
        streakDays++;
      } else {
        break;
      }
    }

    return streakDays;
  }

  /// 모든 달성 기록 조회
  Future<List<Achievement>> getAllAchievements() async {
    return List.from(_achievements);
  }

  /// 특정 목표의 달성 기록 조회
  Future<Achievement?> getAchievementByGoalId(String goalId) async {
    try {
      return _achievements.firstWhere(
        (achievement) => achievement.goalId == goalId,
      );
    } catch (e) {
      return null;
    }
  }
}
