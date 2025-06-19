import '../models/goal.dart';
import '../models/achievement.dart';
import 'web_goal_service.dart';
import 'goal_provider_interface.dart';

/// 웹 환경용 목표 상태 관리 Provider
class WebGoalProvider extends GoalProviderInterface {
  final WebGoalService _goalService = WebGoalService();

  // 상태 변수들
  List<Goal> _goals = [];
  List<Goal> _todayGoals = [];
  List<Achievement> _achievements = [];
  bool _isLoading = false;
  String? _errorMessage;

  // 생성자에서 자동으로 초기화
  WebGoalProvider() {
    _autoInitialize();
  }

  /// 자동 초기화 메소드
  Future<void> _autoInitialize() async {
    try {
      await initialize();
    } catch (e) {
      print('WebGoalProvider 초기화 중 오류: $e');
    }
  }

  // Getters
  @override
  List<Goal> get goals => _goals;
  @override
  List<Goal> get todayGoals => _todayGoals;
  @override
  List<Achievement> get achievements => _achievements;
  @override
  bool get isLoading => _isLoading;
  @override
  String? get errorMessage => _errorMessage;

  /// 오늘 완료된 목표 수
  @override
  int get todayCompletedCount =>
      _todayGoals.where((goal) => goal.isCompleted).length;

  /// 오늘 총 목표 수
  @override
  int get todayTotalCount => _todayGoals.length;

  /// 오늘 달성률 (0.0 ~ 1.0)
  @override
  double get todayAchievementRate =>
      todayTotalCount == 0 ? 0.0 : todayCompletedCount / todayTotalCount;

  /// 초기화
  @override
  Future<void> initialize() async {
    await _goalService.initialize();
    await loadTodayGoals();
    await loadAllGoals();
    await loadAchievements();
  }

  /// 로딩 상태 설정
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// 에러 메시지 설정
  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  /// 에러 메시지 클리어
  @override
  void clearError() {
    _setError(null);
  }

  /// 오늘의 목표 로드
  @override
  Future<void> loadTodayGoals() async {
    try {
      _setLoading(true);
      _setError(null);

      _todayGoals = await _goalService.getTodayGoals();
      notifyListeners();
    } catch (e) {
      _setError('오늘의 목표를 불러오는 중 오류가 발생했습니다: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// 모든 목표 로드
  @override
  Future<void> loadAllGoals() async {
    try {
      _goals = await _goalService.getAllGoals();
      notifyListeners();
    } catch (e) {
      _setError('목표를 불러오는 중 오류가 발생했습니다: ${e.toString()}');
    }
  }

  /// 달성 기록 로드
  @override
  Future<void> loadAchievements() async {
    try {
      _achievements = await _goalService.getAllAchievements();
      notifyListeners();
    } catch (e) {
      _setError('달성 기록을 불러오는 중 오류가 발생했습니다: ${e.toString()}');
    }
  }

  /// 새 목표 추가
  @override
  Future<bool> addGoal(String title) async {
    try {
      _setLoading(true);
      _setError(null);

      final newGoal = await _goalService.addGoal(title);

      // 오늘의 목표 리스트에 추가
      _todayGoals.insert(0, newGoal);

      // 전체 목표 리스트에 추가
      _goals.insert(0, newGoal);

      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// 목표 완료 처리
  @override
  Future<Achievement?> completeGoal(String goalId) async {
    try {
      _setLoading(true);
      _setError(null);

      final achievement = await _goalService.completeGoal(goalId);

      // 오늘의 목표 리스트 업데이트
      final todayIndex = _todayGoals.indexWhere((goal) => goal.id == goalId);
      if (todayIndex != -1) {
        _todayGoals[todayIndex] = _todayGoals[todayIndex].copyWithCompleted();
      }

      // 전체 목표 리스트 업데이트
      final allIndex = _goals.indexWhere((goal) => goal.id == goalId);
      if (allIndex != -1) {
        _goals[allIndex] = _goals[allIndex].copyWithCompleted();
      }

      // 달성 기록 추가
      _achievements.insert(0, achievement);

      notifyListeners();
      return achievement;
    } catch (e) {
      _setError(e.toString());
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// 목표 삭제
  @override
  Future<bool> deleteGoal(String goalId) async {
    try {
      _setLoading(true);
      _setError(null);

      await _goalService.deleteGoal(goalId);

      // 오늘의 목표 리스트에서 제거
      _todayGoals.removeWhere((goal) => goal.id == goalId);

      // 전체 목표 리스트에서 제거
      _goals.removeWhere((goal) => goal.id == goalId);

      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// 목표 수정
  @override
  Future<bool> updateGoal(String goalId, String newTitle) async {
    try {
      _setLoading(true);
      _setError(null);

      final updatedGoal = await _goalService.updateGoal(goalId, newTitle);

      // 오늘의 목표 리스트 업데이트
      final todayIndex = _todayGoals.indexWhere((goal) => goal.id == goalId);
      if (todayIndex != -1) {
        _todayGoals[todayIndex] = updatedGoal;
      }

      // 전체 목표 리스트 업데이트
      final allIndex = _goals.indexWhere((goal) => goal.id == goalId);
      if (allIndex != -1) {
        _goals[allIndex] = updatedGoal;
      }

      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// 특정 날짜의 목표 조회
  @override
  Future<List<Goal>> getGoalsByDate(DateTime date) async {
    try {
      return await _goalService.getGoalsByDate(date);
    } catch (e) {
      _setError('날짜별 목표를 불러오는 중 오류가 발생했습니다: ${e.toString()}');
      return [];
    }
  }

  /// 월별 목표 조회 (달력용)
  @override
  Future<Map<DateTime, List<Goal>>> getMonthlyGoals(DateTime month) async {
    try {
      return await _goalService.getMonthlyGoals(month);
    } catch (e) {
      _setError('월별 목표를 불러오는 중 오류가 발생했습니다: ${e.toString()}');
      return {};
    }
  }

  /// 달성률 계산
  @override
  Future<double> getAchievementRate({int? days}) async {
    try {
      return await _goalService.getAchievementRate(days: days);
    } catch (e) {
      _setError('달성률을 계산하는 중 오류가 발생했습니다: ${e.toString()}');
      return 0.0;
    }
  }

  /// 연속 달성 일수 계산
  @override
  Future<int> getStreakDays() async {
    try {
      return await _goalService.getStreakDays();
    } catch (e) {
      _setError('연속 달성 일수를 계산하는 중 오류가 발생했습니다: ${e.toString()}');
      return 0;
    }
  }

  /// 최근 N일간의 목표 조회
  @override
  Future<List<Goal>> getRecentGoals(int days) async {
    try {
      return await _goalService.getRecentGoals(days);
    } catch (e) {
      _setError('최근 목표를 불러오는 중 오류가 발생했습니다: ${e.toString()}');
      return [];
    }
  }

  /// 데이터 새로고침
  @override
  Future<void> refresh() async {
    await Future.wait([loadTodayGoals(), loadAllGoals(), loadAchievements()]);
  }
}
