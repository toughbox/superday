import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/goal_provider_interface.dart';
import '../models/goal.dart';
import '../models/achievement.dart';
import '../constants/colors.dart';
import '../constants/strings.dart';
import '../widgets/goal_item.dart';
import '../widgets/goal_detail_dialog.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // 통계 데이터
  int _streakDays = 0;
  double _todayRate = 0.0;
  double _weeklyRate = 0.0;
  double _monthlyRate = 0.0;
  double _overallRate = 0.0;

  List<Achievement> _achievements = [];
  List<Goal> _allGoals = [];
  List<Goal> _todayGoals = [];
  List<Goal> _weekGoals = [];
  List<Goal> _monthGoals = [];

  // 필터링 상태
  String _searchText = '';
  String _selectedFilter = '전체'; // 전체, 7일, 30일
  bool _showCompletedOnly = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// 데이터 로드
  Future<void> _loadData() async {
    final goalProvider = context.read<GoalProviderInterface>();

    final results = await Future.wait([
      goalProvider.getStreakDays(),
      goalProvider.getAchievementRate(days: 7),
      goalProvider.getAchievementRate(days: 30),
      goalProvider.getAchievementRate(),
      goalProvider.loadAchievements().then((_) => goalProvider.achievements),
      goalProvider.getRecentGoals(30),
    ]);

    setState(() {
      _streakDays = results[0] as int;
      _weeklyRate = results[1] as double;
      _monthlyRate = results[2] as double;
      _overallRate = results[3] as double;
      _achievements = results[4] as List<Achievement>;
      _allGoals = results[5] as List<Goal>;
    });

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekStart = today.subtract(Duration(days: now.weekday - 1));
    final monthStart = DateTime(now.year, now.month, 1);

    setState(() {
      _todayGoals =
          _allGoals.where((goal) {
            final goalDate = DateTime(
              goal.createdDate.year,
              goal.createdDate.month,
              goal.createdDate.day,
            );
            return goalDate == today;
          }).toList();

      _weekGoals =
          _allGoals.where((goal) {
            final goalDate = DateTime(
              goal.createdDate.year,
              goal.createdDate.month,
              goal.createdDate.day,
            );
            return goalDate.isAfter(
                  weekStart.subtract(const Duration(days: 1)),
                ) &&
                goalDate.isBefore(today.add(const Duration(days: 1)));
          }).toList();

      _monthGoals =
          _allGoals.where((goal) {
            return goal.createdDate.year == now.year &&
                goal.createdDate.month == now.month;
          }).toList();

      _todayRate = _calculateRate(_todayGoals);
      _weeklyRate = _calculateRate(_weekGoals);
      _monthlyRate = _calculateRate(_monthGoals);
      _overallRate = _calculateRate(_allGoals);
    });
  }

  double _calculateRate(List<Goal> goals) {
    if (goals.isEmpty) return 0.0;
    final completed = goals.where((g) => g.isCompleted).length;
    return completed / goals.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          '성취 기록',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(fontWeight: FontWeight.w600),
          tabs: const [
            Tab(text: '오늘'),
            Tab(text: '이번 주'),
            Tab(text: '이번 달'),
            Tab(text: '전체'),
          ],
        ),
      ),
      body: Column(
        children: [
          // 통계 카드
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: AppColors.primaryGradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                const Text(
                  '📊 성취 통계',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatItem('전체 목표', '${_allGoals.length}개'),
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: Colors.white.withOpacity(0.3),
                    ),
                    Expanded(
                      child: _buildStatItem(
                        '완료된 목표',
                        '${_allGoals.where((g) => g.isCompleted).length}개',
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: Colors.white.withOpacity(0.3),
                    ),
                    Expanded(
                      child: _buildStatItem(
                        '전체 달성률',
                        '${(_overallRate * 100).toInt()}%',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 기간별 달성률 요약
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildProgressItem('오늘', _todayRate, AppColors.success),
                const SizedBox(width: 8),
                _buildProgressItem('이번 주', _weeklyRate, AppColors.primary),
                const SizedBox(width: 8),
                _buildProgressItem('이번 달', _monthlyRate, AppColors.secondary),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 탭뷰 목록
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildGoalsList(_todayGoals, '오늘 설정한 목표가 없습니다'),
                _buildGoalsList(_weekGoals, '이번 주 설정한 목표가 없습니다'),
                _buildGoalsList(_monthGoals, '이번 달 설정한 목표가 없습니다'),
                _buildGoalsList(_allGoals, '설정한 목표가 없습니다'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.8)),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildProgressItem(String label, double rate, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              '${(rate * 100).toInt()}%',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: rate,
              backgroundColor: AppColors.border,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalsList(List<Goal> goals, String emptyMessage) {
    if (goals.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history_rounded,
              size: 64,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: goals.length,
      itemBuilder: (context, index) {
        final goal = goals[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          child: GoalItem(
            goal: goal,
            onTap: () => _showGoalDetail(goal),
            onComplete: goal.isCompleted ? null : () => _completeGoal(goal.id), // 완료되지 않은 목표만 완료 가능
            onEdit: null, // 기록 화면에서는 수정 기능 비활성화
            onDelete: () => _deleteGoal(goal.id),
          ),
        );
      },
    );
  }

  void _completeGoal(String goalId) async {
    final goalProvider = context.read<GoalProviderInterface>();
    await goalProvider.completeGoal(goalId);
    await _loadData(); // 데이터 새로고침

    // 목표가 오늘 것이라면 오늘의 모든 목표 완료 시 축하 메시지 표시
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final completedGoal = _allGoals.firstWhere((g) => g.id == goalId);
    final goalDate = DateTime(
      completedGoal.createdDate.year,
      completedGoal.createdDate.month,
      completedGoal.createdDate.day,
    );

    if (goalDate == today) {
      final todayGoals = _todayGoals;
      final allCompleted = todayGoals.every((g) => g.isCompleted);

      if (allCompleted && todayGoals.isNotEmpty && mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  '🎉',
                  style: TextStyle(fontSize: 60),
                ),
                const SizedBox(height: 16),
                const Text(
                  '오늘의 모든 목표를 달성하셨습니다!\n훌륭해요!',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    '확인',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    }
  }

  void _showGoalDetail(Goal goal) {
    showDialog(
      context: context,
      builder: (context) => GoalDetailDialog(
        goal: goal,
        onComplete: goal.isCompleted ? null : () => _completeGoal(goal.id),
      ),
    );
  }

  void _deleteGoal(String goalId) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text(
              '목표 삭제',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: const Text('정말로 이 목표를 삭제하시겠습니까?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('취소'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  final goalProvider = context.read<GoalProviderInterface>();
                  await goalProvider.deleteGoal(goalId);
                  await _loadData(); // 데이터 새로고침
                },
                style: TextButton.styleFrom(foregroundColor: AppColors.danger),
                child: const Text('삭제'),
              ),
            ],
          ),
    );
  }
}
