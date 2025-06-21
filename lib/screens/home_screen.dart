import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/goal_provider_interface.dart';
import '../models/goal.dart';
import '../constants/colors.dart';
import '../constants/strings.dart';
import '../widgets/add_goal_dialog.dart';
import '../widgets/goal_item.dart';
import '../widgets/celebration_dialog.dart';
import 'calendar_screen.dart';
import 'history_screen.dart';
import 'settings_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _fabAnimationController;
  late Animation<double> _fabAnimation;

  @override
  void initState() {
    super.initState();
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _fabAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fabAnimationController, curve: Curves.easeOut),
    );
    _fabAnimationController.forward();
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: AppColors.backgroundGradient,
          ),
        ),
        child: _getSelectedScreen(),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: '홈'),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month_rounded),
              label: '캘린더',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history_rounded),
              label: '기록',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_rounded),
              label: '설정',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textSecondary,
          backgroundColor: Colors.transparent,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
          onTap: _onItemTapped,
        ),
      ),
      floatingActionButton:
          _selectedIndex == 0
              ? ScaleTransition(
                scale: _fabAnimation,
                child: FloatingActionButton.extended(
                  onPressed: _addGoal,
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.textOnPrimary,
                  icon: const Icon(Icons.add_rounded),
                  label: const Text(
                    '목표 추가',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  elevation: 8,
                  highlightElevation: 12,
                ),
              )
              : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _getSelectedScreen() {
    switch (_selectedIndex) {
      case 0:
        return const HomeScreen();
      case 1:
        return const CalendarScreen();
      case 2:
        return const HistoryScreen();
      case 3:
        return const SettingsScreen();
      default:
        return const HomeScreen();
    }
  }

  void _addGoal() {
    showDialog(context: context, builder: (context) => const AddGoalDialog());
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _headerAnimationController;
  late AnimationController _statsAnimationController;
  late Animation<Offset> _headerSlideAnimation;
  late Animation<double> _statsScaleAnimation;

  @override
  void initState() {
    super.initState();
    _headerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _statsAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _headerSlideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _headerAnimationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _statsScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _statsAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    _headerAnimationController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _statsAnimationController.forward();
    });
  }

  @override
  void dispose() {
    _headerAnimationController.dispose();
    _statsAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GoalProviderInterface>(
      builder: (context, goalProvider, child) {
        final goals = goalProvider.goals;
        final completedGoals = goals.where((goal) => goal.isCompleted).toList();
        final pendingGoals = goals.where((goal) => !goal.isCompleted).toList();
        final completionRate =
            goals.isNotEmpty ? (completedGoals.length / goals.length) : 0.0;

        return CustomScrollView(
          slivers: [
            // 헤더 섹션
            SliverToBoxAdapter(
              child: SlideTransition(
                position: _headerSlideAnimation,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(24, 60, 24, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getGreeting(),
                        style: const TextStyle(
                          fontSize: 16,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '오늘도 목표를 달성해보세요!',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // 통계 카드
            SliverToBoxAdapter(
              child: ScaleTransition(
                scale: _statsScaleAnimation,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: AppColors.primaryGradient,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '오늘의 진행률',
                              style: TextStyle(
                                fontSize: 16,
                                color: AppColors.textOnPrimary.withOpacity(0.9),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${(completionRate * 100).toInt()}%',
                              style: const TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textOnPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${completedGoals.length}/${goals.length} 목표 달성',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textOnPrimary.withOpacity(0.8),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: AppColors.surface.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(40),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 60,
                              height: 60,
                              child: CircularProgressIndicator(
                                value: completionRate,
                                strokeWidth: 6,
                                backgroundColor: AppColors.surface.withOpacity(
                                  0.3,
                                ),
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  AppColors.surface,
                                ),
                              ),
                            ),
                            Icon(
                              completionRate == 1.0
                                  ? Icons.celebration
                                  : Icons.emoji_events,
                              color: AppColors.surface,
                              size: 28,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 32)),

            // 목표 섹션 헤더
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '오늘의 목표',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (goals.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${goals.length}개',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // 목표 리스트
            goals.isEmpty
                ? SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceVariant,
                            borderRadius: BorderRadius.circular(60),
                          ),
                          child: const Icon(
                            Icons.flag_rounded,
                            size: 60,
                            color: AppColors.textTertiary,
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          '첫 목표를 설정해보세요!',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          '아래 + 버튼을 눌러 새로운 목표를 추가하세요',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
                : SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final goal = goals[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: GoalItem(
                          goal: goal,
                          onTap: null, // 카드 클릭으로는 완료처리 안 함
                          onComplete:
                              goal.isCompleted
                                  ? null
                                  : () => _completeGoal(goal),
                          onEdit:
                              goal.isCompleted ? null : () => _editGoal(goal),
                          onDelete: () => _deleteGoal(goal),
                        ),
                      );
                    }, childCount: goals.length),
                  ),
                ),

            // 하단 여백 (FAB 공간)
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        );
      },
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return '좋은 아침이에요 ☀️';
    } else if (hour < 18) {
      return '좋은 오후에요 🌤️';
    } else {
      return '좋은 저녁이에요 🌙';
    }
  }

  void _toggleGoal(Goal goal) async {
    final goalProvider = context.read<GoalProviderInterface>();

    if (goal.isCompleted) {
      // 이미 완료된 목표를 다시 미완료로 되돌리는 기능은 제거
      return;
    } else {
      await goalProvider.completeGoal(goal.id);

      // 모든 목표 완료 시 축하 메시지
      final allGoals = goalProvider.goals;
      final allCompleted = allGoals.every((g) => g.isCompleted);

      if (allCompleted && allGoals.isNotEmpty && mounted) {
        showDialog(
          context: context,
          builder:
              (context) =>
                  CelebrationDialog(message: "🎉 모든 목표를 달성하셨습니다!\n훌륭해요!"),
        );
      }
    }
  }

  void _completeGoal(Goal goal) async {
    _toggleGoal(goal);
  }

  void _editGoal(Goal goal) {
    showDialog(
      context: context,
      builder: (context) => AddGoalDialog(goal: goal),
    );
  }

  void _deleteGoal(Goal goal) {
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
            content: Text('정말로 "${goal.title}" 목표를 삭제하시겠습니까?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('취소'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  final goalProvider = context.read<GoalProviderInterface>();
                  await goalProvider.deleteGoal(goal.id);
                },
                style: TextButton.styleFrom(foregroundColor: AppColors.danger),
                child: const Text('삭제'),
              ),
            ],
          ),
    );
  }
}
