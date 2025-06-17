import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/goal_provider_interface.dart';
import '../constants/colors.dart';
import '../constants/strings.dart';
import '../widgets/goal_item.dart';
import '../widgets/add_goal_dialog.dart';
import '../widgets/celebration_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // 화면 로드 시 데이터 초기화!
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GoalProviderInterface>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Consumer<GoalProviderInterface>(
          builder: (context, goalProvider, child) {
            return RefreshIndicator(
              onRefresh: () => goalProvider.refresh(),
              color: AppColors.primary,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  // 앱바
                  _buildSliverAppBar(goalProvider),
                  
                  // 진행 상황 카드
                  _buildProgressCard(goalProvider),
                  
                  // 목표 추가 버튼
                  _buildAddGoalButton(),
                  
                  // 목표 리스트
                  _buildGoalsList(goalProvider),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  /// 슬리버 앱바 구성
  Widget _buildSliverAppBar(GoalProviderInterface goalProvider) {
    return SliverAppBar(
      expandedHeight: 100,
      floating: false,
      pinned: true,
      backgroundColor: AppColors.primary,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          AppStrings.todayGoals,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      actions: [
        if (goalProvider.isLoading)
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          ),
      ],
    );
  }

  /// 진행 상황 카드
  Widget _buildProgressCard(GoalProviderInterface goalProvider) {
    final completedCount = goalProvider.todayCompletedCount;
    final totalCount = goalProvider.todayTotalCount;
    final progress = goalProvider.todayAchievementRate;

    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.secondary, AppColors.accent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppStrings.todayProgress,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  '$completedCount/$totalCount',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white.withOpacity(0.3),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              borderRadius: BorderRadius.circular(8),
              minHeight: 8,
            ),
            const SizedBox(height: 8),
            Text(
              '${(progress * 100).toInt()}% 완료',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 목표 추가 버튼
  Widget _buildAddGoalButton() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: ElevatedButton.icon(
          onPressed: () => _showAddGoalDialog(),
          icon: const Icon(Icons.add, color: Colors.white),
          label: Text(
            AppStrings.addGoal,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 4,
          ),
        ),
      ),
    );
  }

  /// 목표 리스트
  Widget _buildGoalsList(GoalProviderInterface goalProvider) {
    if (goalProvider.errorMessage != null) {
      return SliverToBoxAdapter(
        child: Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.red.shade200),
          ),
          child: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.red.shade600),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  goalProvider.errorMessage!,
                  style: TextStyle(
                    color: Colors.red.shade600,
                    fontSize: 14,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => goalProvider.clearError(),
                child: const Text('닫기'),
              ),
            ],
          ),
        ),
      );
    }

    final todayGoals = goalProvider.todayGoals;

    if (todayGoals.isEmpty) {
      return SliverToBoxAdapter(
        child: Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(
                Icons.track_changes,
                size: 64,
                color: AppColors.textSecondary,
              ),
              const SizedBox(height: 16),
              Text(
                AppStrings.noGoalsToday,
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                AppStrings.addFirstGoal,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final goal = todayGoals[index];
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: GoalItem(
              goal: goal,
              onTap: () => _handleGoalTap(goal.id),
              onComplete: () => _handleGoalComplete(goal.id),
              onEdit: () => _handleGoalEdit(goal),
              onDelete: () => _handleGoalDelete(goal.id),
            ),
          );
        },
        childCount: todayGoals.length,
      ),
    );
  }

  /// 목표 추가 다이얼로그 표시
  void _showAddGoalDialog() {
    showDialog(
      context: context,
      builder: (context) => const AddGoalDialog(),
    );
  }

  /// 목표 탭 처리
  void _handleGoalTap(String goalId) {
    // 목표 상세 보기나 수정 기능 (향후 구현)
  }

  /// 목표 완료 처리
  void _handleGoalComplete(String goalId) async {
    final goalProvider = context.read<GoalProviderInterface>();
    final achievement = await goalProvider.completeGoal(goalId);
    
    if (achievement != null && mounted) {
      // 축하 메시지 다이얼로그 표시
      showDialog(
        context: context,
        builder: (context) => CelebrationDialog(
          message: achievement.celebrationMessage,
        ),
      );
    }
  }

  /// 목표 수정 처리
  void _handleGoalEdit(goal) {
    showDialog(
      context: context,
      builder: (context) => AddGoalDialog(
        goal: goal,
      ),
    );
  }

  /// 목표 삭제 처리
  void _handleGoalDelete(String goalId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('목표 삭제'),
        content: const Text('정말로 이 목표를 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<GoalProviderInterface>().deleteGoal(goalId);
            },
            child: const Text(
              '삭제',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
} 