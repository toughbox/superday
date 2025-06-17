import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../services/goal_provider_interface.dart';
import '../models/goal.dart';
import '../constants/colors.dart';
import '../constants/strings.dart';
import '../widgets/goal_item.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late final ValueNotifier<List<Goal>> _selectedGoals;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<Goal>> _monthlyGoals = {};

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _selectedGoals = ValueNotifier(_getGoalsForDay(_selectedDay!));
    _loadMonthlyGoals();
  }

  @override
  void dispose() {
    _selectedGoals.dispose();
    super.dispose();
  }

  /// 월별 목표 데이터 로드
  Future<void> _loadMonthlyGoals() async {
    final goalProvider = context.read<GoalProviderInterface>();
    final monthlyGoals = await goalProvider.getMonthlyGoals(_focusedDay);
    
    setState(() {
      _monthlyGoals = monthlyGoals;
    });
    
    // 선택된 날짜의 목표 업데이트
    if (_selectedDay != null) {
      _selectedGoals.value = _getGoalsForDay(_selectedDay!);
    }
  }

  /// 특정 날짜의 목표 조회
  List<Goal> _getGoalsForDay(DateTime day) {
    final dayKey = DateTime(day.year, day.month, day.day);
    return _monthlyGoals[dayKey] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          '목표 달력',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.primaryLavender,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadMonthlyGoals,
          ),
        ],
      ),
      body: Column(
        children: [
          // 캘린더 위젯
          Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TableCalendar<Goal>(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              eventLoader: _getGoalsForDay,
              startingDayOfWeek: StartingDayOfWeek.monday,
              selectedDayPredicate: (day) {
                return _selectedDay != null && isSameDay(_selectedDay!, day);
              },
              onDaySelected: (selectedDay, focusedDay) {
                if (!isSameDay(_selectedDay, selectedDay)) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                  _selectedGoals.value = _getGoalsForDay(selectedDay);
                }
              },
              onFormatChanged: (format) {
                if (_calendarFormat != format) {
                  setState(() {
                    _calendarFormat = format;
                  });
                }
              },
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
                _loadMonthlyGoals();
              },
              // 캘린더 스타일
              calendarStyle: CalendarStyle(
                outsideDaysVisible: false,
                weekendTextStyle: TextStyle(color: AppColors.textSecondary),
                holidayTextStyle: TextStyle(color: AppColors.textSecondary),
                selectedDecoration: BoxDecoration(
                  color: AppColors.primaryLavender,
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: AppColors.primaryMint,
                  shape: BoxShape.circle,
                ),
                markerDecoration: BoxDecoration(
                  color: AppColors.primaryYellow,
                  shape: BoxShape.circle,
                ),
                markersMaxCount: 3,
              ),
              // 헤더 스타일
              headerStyle: HeaderStyle(
                formatButtonVisible: true,
                titleCentered: true,
                formatButtonShowsNext: false,
                formatButtonDecoration: BoxDecoration(
                  color: AppColors.primaryLavender,
                  borderRadius: BorderRadius.circular(12),
                ),
                formatButtonTextStyle: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
                leftChevronIcon: Icon(
                  Icons.chevron_left,
                  color: AppColors.primaryLavender,
                ),
                rightChevronIcon: Icon(
                  Icons.chevron_right,
                  color: AppColors.primaryLavender,
                ),
              ),
            ),
          ),
          
          // 선택된 날짜 정보
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primaryLavender, AppColors.primaryMint],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _selectedDay != null
                          ? '${_selectedDay!.month}월 ${_selectedDay!.day}일'
                          : '날짜를 선택하세요',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    ValueListenableBuilder<List<Goal>>(
                      valueListenable: _selectedGoals,
                      builder: (context, goals, _) {
                        final completedCount = goals.where((g) => g.isCompleted).length;
                        return Text(
                          '목표 ${goals.length}개 중 ${completedCount}개 달성',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        );
                      },
                    ),
                  ],
                ),
                ValueListenableBuilder<List<Goal>>(
                  valueListenable: _selectedGoals,
                  builder: (context, goals, _) {
                    if (goals.isEmpty) return const SizedBox();
                    
                    final completionRate = goals.where((g) => g.isCompleted).length / goals.length;
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 50,
                          height: 50,
                          child: CircularProgressIndicator(
                            value: completionRate,
                            backgroundColor: Colors.white.withOpacity(0.3),
                            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                            strokeWidth: 4,
                          ),
                        ),
                        Text(
                          '${(completionRate * 100).toInt()}%',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
          
          // 선택된 날짜의 목표 목록
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ValueListenableBuilder<List<Goal>>(
                valueListenable: _selectedGoals,
                builder: (context, goals, _) {
                  if (goals.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.event_available,
                            size: 64,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _selectedDay != null && _selectedDay!.day == DateTime.now().day &&
                                    _selectedDay!.month == DateTime.now().month &&
                                    _selectedDay!.year == DateTime.now().year
                                ? '오늘 설정된 목표가 없습니다'
                                : '이 날짜에 설정된 목표가 없습니다',
                            style: TextStyle(
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
                          onTap: () {},
                          onComplete: goal.isCompleted ? null : () => _completeGoal(goal.id),
                          onEdit: goal.isCompleted ? null : () => _editGoal(goal),
                          onDelete: () => _deleteGoal(goal.id),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 목표 완료 처리
  void _completeGoal(String goalId) async {
    final goalProvider = context.read<GoalProviderInterface>();
    await goalProvider.completeGoal(goalId);
    await _loadMonthlyGoals();
  }

  /// 목표 수정
  void _editGoal(Goal goal) {
    // 목표 수정 다이얼로그 (향후 구현)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('목표 수정 기능은 홈 화면에서 이용하세요')),
    );
  }

  /// 목표 삭제
  void _deleteGoal(String goalId) {
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
            onPressed: () async {
              Navigator.pop(context);
              final goalProvider = context.read<GoalProviderInterface>();
              await goalProvider.deleteGoal(goalId);
              await _loadMonthlyGoals();
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