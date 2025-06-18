import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/goal_provider_interface.dart';
import '../models/goal.dart';
import '../models/achievement.dart';
import '../constants/colors.dart';
import '../constants/strings.dart';

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
  double _weeklyRate = 0.0;
  double _monthlyRate = 0.0;
  double _overallRate = 0.0;

  List<Achievement> _achievements = [];
  List<Goal> _recentGoals = [];

  // 필터링 상태
  String _searchText = '';
  String _selectedFilter = '전체'; // 전체, 7일, 30일
  bool _showCompletedOnly = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
      _recentGoals = results[5] as List<Goal>;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight, // Genesis Travel 테마 배경
      appBar: AppBar(
        title: const Text(
          '달성 히스토리',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 18,
          ),
        ),
        backgroundColor: AppColors.skyBlue, // 하늘색 배경
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadData,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.normal,
            fontSize: 14,
          ),
          tabs: const [
            Tab(text: '통계', icon: Icon(Icons.analytics)),
            Tab(text: '기록', icon: Icon(Icons.history)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildStatisticsTab(), _buildHistoryTab()],
      ),
    );
  }

  /// 통계 탭 구성
  Widget _buildStatisticsTab() {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 연속 달성 일수 카드
            _buildStreakCard(),

            const SizedBox(height: 16),

            // 달성률 통계
            _buildAchievementRatesCard(),

            const SizedBox(height: 16),

            // 최근 활동
            _buildRecentActivityCard(),
          ],
        ),
      ),
    );
  }

  /// 기록 탭 구성
  Widget _buildHistoryTab() {
    return Column(
      children: [
        // 필터링 컨트롤
        _buildFilterControls(),

        // 기록 리스트
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadData,
            child:
                _getFilteredAchievements().isEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.emoji_events,
                            size: 64,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _achievements.isEmpty
                                ? '아직 달성한 목표가 없습니다'
                                : '조건에 맞는 기록이 없습니다',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _achievements.isEmpty
                                ? '첫 번째 목표를 달성해보세요!'
                                : '다른 조건으로 검색해보세요',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    )
                    : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _getFilteredAchievements().length,
                      itemBuilder: (context, index) {
                        final achievement = _getFilteredAchievements()[index];
                        return _buildAchievementItem(achievement);
                      },
                    ),
          ),
        ),
      ],
    );
  }

  /// 연속 달성 일수 카드
  Widget _buildStreakCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: AppColors.skyGradient, // Genesis Travel 하늘 그라데이션
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4A90E2).withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.local_fire_department,
              size: 32,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '연속 달성',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '$_streakDays일',
                  style: const TextStyle(
                    fontSize: 28,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _streakDays > 0 ? '계속 이 상태를 유지해보세요!' : '새로운 연속 달성을 시작해보세요!',
                  style: const TextStyle(fontSize: 12, color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 달성률 통계 카드
  Widget _buildAchievementRatesCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '달성률 통계',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          _buildProgressItem('이번 주', _weeklyRate, AppColors.journeyStart),
          const SizedBox(height: 16),
          _buildProgressItem('이번 달', _monthlyRate, AppColors.journeyProgress),
          const SizedBox(height: 16),
          _buildProgressItem('전체', _overallRate, AppColors.journeyComplete),
        ],
      ),
    );
  }

  /// 진행률 아이템
  Widget _buildProgressItem(String label, double rate, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${(rate * 100).toInt()}%',
              style: TextStyle(
                fontSize: 14,
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: rate,
          backgroundColor: Colors.grey.shade200,
          valueColor: AlwaysStoppedAnimation<Color>(color),
          borderRadius: BorderRadius.circular(4),
          minHeight: 6,
        ),
      ],
    );
  }

  /// 최근 활동 카드
  Widget _buildRecentActivityCard() {
    final recentCompletedGoals =
        _recentGoals.where((goal) => goal.isCompleted).take(5).toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '최근 달성한 목표',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          if (recentCompletedGoals.isEmpty)
            Text(
              '최근 달성한 목표가 없습니다',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            )
          else
            ...recentCompletedGoals.map(
              (goal) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      size: 16,
                      color: AppColors.success,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        goal.title,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    Text(
                      goal.formattedCompletedDate,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// 필터링 컨트롤
  Widget _buildFilterControls() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // 검색창
          TextField(
            onChanged: (value) {
              setState(() {
                _searchText = value;
              });
            },
            decoration: InputDecoration(
              hintText: '목표 제목으로 검색...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),

          const SizedBox(height: 12),

          // 필터 버튼들
          Row(
            children: [
              // 기간 필터
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedFilter,
                  onChanged: (value) {
                    setState(() {
                      _selectedFilter = value!;
                    });
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  items:
                      ['전체', '7일', '30일'].map((filter) {
                        return DropdownMenuItem(
                          value: filter,
                          child: Text(filter),
                        );
                      }).toList(),
                ),
              ),

              const SizedBox(width: 12),

              // 달성 상태 필터
              FilterChip(
                label: const Text('달성한 목표만'),
                selected: _showCompletedOnly,
                onSelected: (selected) {
                  setState(() {
                    _showCompletedOnly = selected;
                  });
                },
                selectedColor: AppColors.primaryMint.withOpacity(0.3),
                checkmarkColor: AppColors.primaryMint,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 필터링된 달성 기록 가져오기
  List<Achievement> _getFilteredAchievements() {
    List<Achievement> filtered = List.from(_achievements);

    // 검색 텍스트로 필터링
    if (_searchText.isNotEmpty) {
      filtered =
          filtered
              .where(
                (achievement) => achievement.celebrationMessage
                    .toLowerCase()
                    .contains(_searchText.toLowerCase()),
              )
              .toList();
    }

    // 기간으로 필터링
    if (_selectedFilter != '전체') {
      final now = DateTime.now();
      final filterDays = _selectedFilter == '7일' ? 7 : 30;
      final filterDate = now.subtract(Duration(days: filterDays));

      filtered =
          filtered
              .where(
                (achievement) => achievement.achievedDate.isAfter(filterDate),
              )
              .toList();
    }

    // 달성 상태로 필터링 (Achievement는 이미 달성된 것들이므로 여기서는 의미없지만 구조상 유지)

    return filtered;
  }

  /// 달성 기록 아이템
  Widget _buildAchievementItem(Achievement achievement) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF39C12).withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.emoji_events,
              color: Color(0xFFF39C12),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  achievement.celebrationMessage,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  achievement.formattedAchievedDate,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (achievement.isToday)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF2ECC71),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                '오늘',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
