import 'dart:math';
import '../models/goal.dart';
import '../models/achievement.dart';
import '../constants/strings.dart';
import 'database_helper.dart';

/// 목표 관리 서비스 클래스
class GoalService {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  /// 고유 ID 생성
  String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  /// 랜덤 축하 메시지 선택
  String _getRandomCelebrationMessage() {
    final random = Random();
    return AppStrings.celebrationMessages[
        random.nextInt(AppStrings.celebrationMessages.length)];
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
    final duplicateGoal = todayGoals.where((goal) => 
        goal.title.toLowerCase() == title.trim().toLowerCase()).firstOrNull;
    
    if (duplicateGoal != null) {
      throw Exception(AppStrings.goalAlreadyExists);
    }

    // 새 목표 생성
    final goal = Goal(
      id: _generateId(),
      title: title.trim(),
      createdDate: DateTime.now(),
    );

    await _databaseHelper.insertGoal(goal);
    return goal;
  }

  /// 목표 완료 처리
  Future<Achievement> completeGoal(String goalId) async {
    // 목표 조회
    final goals = await _databaseHelper.getAllGoals();
    final goal = goals.where((g) => g.id == goalId).firstOrNull;
    
    if (goal == null) {
      throw Exception('목표를 찾을 수 없습니다.');
    }

    if (goal.isCompleted) {
      throw Exception('이미 완료된 목표입니다.');
    }

    // 목표 완료 처리
    final completedGoal = goal.copyWithCompleted();
    await _databaseHelper.updateGoal(completedGoal);

    // 달성 기록 생성
    final achievement = Achievement(
      id: _generateId(),
      goalId: goalId,
      achievedDate: DateTime.now(),
      celebrationMessage: _getRandomCelebrationMessage(),
    );

    await _databaseHelper.insertAchievement(achievement);
    return achievement;
  }

  /// 목표 삭제
  Future<void> deleteGoal(String goalId) async {
    await _databaseHelper.deleteGoal(goalId);
  }

  /// 목표 수정
  Future<Goal> updateGoal(String goalId, String newTitle) async {
    if (newTitle.trim().isEmpty) {
      throw Exception(AppStrings.goalEmpty);
    }
    
    if (newTitle.length > 50) {
      throw Exception(AppStrings.goalTooLong);
    }

    final goals = await _databaseHelper.getAllGoals();
    final goal = goals.where((g) => g.id == goalId).firstOrNull;
    
    if (goal == null) {
      throw Exception('목표를 찾을 수 없습니다.');
    }

    final updatedGoal = goal.copyWith(title: newTitle.trim());
    await _databaseHelper.updateGoal(updatedGoal);
    return updatedGoal;
  }

  /// 오늘의 목표 조회
  Future<List<Goal>> getTodayGoals() async {
    final today = DateTime.now();
    return await _databaseHelper.getGoalsByDate(today);
  }

  /// 모든 목표 조회
  Future<List<Goal>> getAllGoals() async {
    return await _databaseHelper.getAllGoals();
  }

  /// 특정 날짜의 목표 조회
  Future<List<Goal>> getGoalsByDate(DateTime date) async {
    return await _databaseHelper.getGoalsByDate(date);
  }

  /// 날짜 범위로 목표 조회
  Future<List<Goal>> getGoalsByDateRange(DateTime startDate, DateTime endDate) async {
    return await _databaseHelper.getGoalsByDateRange(startDate, endDate);
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
    
    for (int i = 0; i < 365; i++) { // 최대 1년까지 확인
      final checkDate = today.subtract(Duration(days: i));
      final dateKey = checkDate.toIso8601String().substring(0, 10);
      
      final dayGoals = goalsByDate[dateKey] ?? [];
      
      // 그날 목표가 없으면 연속 끊김
      if (dayGoals.isEmpty) {
        if (i == 0) continue; // 오늘 목표가 없어도 계속 (아직 설정 안 했을 수 있음)
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
    return await _databaseHelper.getAllAchievements();
  }

  /// 특정 목표의 달성 기록 조회
  Future<Achievement?> getAchievementByGoalId(String goalId) async {
    return await _databaseHelper.getAchievementByGoalId(goalId);
  }
} 