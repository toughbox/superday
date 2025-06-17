import 'package:flutter/foundation.dart';
import '../models/goal.dart';
import '../models/achievement.dart';

/// 목표 관리 Provider 인터페이스
abstract class GoalProviderInterface extends ChangeNotifier {
  // 상태 변수들
  List<Goal> get goals;
  List<Goal> get todayGoals;
  List<Achievement> get achievements;
  bool get isLoading;
  String? get errorMessage;

  /// 오늘 완료된 목표 수
  int get todayCompletedCount;

  /// 오늘 총 목표 수
  int get todayTotalCount;

  /// 오늘 달성률 (0.0 ~ 1.0)
  double get todayAchievementRate;

  /// 초기화
  Future<void> initialize();

  /// 에러 메시지 클리어
  void clearError();

  /// 오늘의 목표 로드
  Future<void> loadTodayGoals();

  /// 모든 목표 로드
  Future<void> loadAllGoals();

  /// 달성 기록 로드
  Future<void> loadAchievements();

  /// 새 목표 추가
  Future<bool> addGoal(String title);

  /// 목표 완료 처리
  Future<Achievement?> completeGoal(String goalId);

  /// 목표 삭제
  Future<bool> deleteGoal(String goalId);

  /// 목표 수정
  Future<bool> updateGoal(String goalId, String newTitle);

  /// 특정 날짜의 목표 조회
  Future<List<Goal>> getGoalsByDate(DateTime date);

  /// 월별 목표 조회 (달력용)
  Future<Map<DateTime, List<Goal>>> getMonthlyGoals(DateTime month);

  /// 달성률 계산
  Future<double> getAchievementRate({int? days});

  /// 연속 달성 일수 계산
  Future<int> getStreakDays();

  /// 최근 N일간의 목표 조회
  Future<List<Goal>> getRecentGoals(int days);

  /// 데이터 새로고침
  Future<void> refresh();
} 