import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'constants/colors.dart';
import 'constants/themes.dart';
import 'constants/strings.dart';
import 'services/goal_provider.dart';
import 'services/web_goal_provider.dart';
import 'services/goal_provider_interface.dart';
import 'screens/home_screen.dart';
import 'screens/calendar_screen.dart';
import 'screens/history_screen.dart';
import 'screens/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SuperDayApp());
}

class SuperDayApp extends StatelessWidget {
  const SuperDayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<GoalProviderInterface>(
      create: (context) => kIsWeb ? WebGoalProvider() : GoalProvider(),
      child: MaterialApp(
        title: AppStrings.appName,
        theme: AppThemes.lightTheme,
        home: const MainScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  bool _isInitialized = false;

  // 실제 화면들
  final List<Widget> _screens = [
    const HomeScreen(),
    const CalendarScreen(),
    const HistoryScreen(),
    const SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _initializeProvider();
    }
  }

  /// Provider 초기화
  Future<void> _initializeProvider() async {
    final goalProvider = context.read<GoalProviderInterface>();
    await goalProvider.initialize();
    if (mounted) {
      setState(() {
        _isInitialized = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: AppColors.primaryMint),
              const SizedBox(height: 16),
              Text(
                '앱을 준비하고 있습니다...',
                style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: AppColors.primaryMint,
        unselectedItemColor: AppColors.textSecondary,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: AppStrings.homeTab,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: AppStrings.calendarTab,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: AppStrings.historyTab,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: AppStrings.settingsTab,
          ),
        ],
      ),
    );
  }
}

// 임시 화면들 - 각 탭의 기본 틀
class HomeTabPlaceholder extends StatelessWidget {
  const HomeTabPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.todayGoal)),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.star, size: 64, color: AppColors.primaryMint),
            SizedBox(height: 16),
            Text(
              '홈 화면',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '오늘의 목표를 설정하고 달성해보세요!',
              style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class CalendarTabPlaceholder extends StatelessWidget {
  const CalendarTabPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.calendarTab)),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_month,
              size: 64,
              color: AppColors.primaryLavender,
            ),
            SizedBox(height: 16),
            Text(
              '달력 화면',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '목표 달성 현황을 달력으로 확인하세요!',
              style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class HistoryTabPlaceholder extends StatelessWidget {
  const HistoryTabPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.historyTab)),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 64, color: AppColors.primaryYellow),
            SizedBox(height: 16),
            Text(
              '히스토리 화면',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '지난 목표들과 달성률을 확인하세요!',
              style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class SettingsTabPlaceholder extends StatelessWidget {
  const SettingsTabPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.settingsTab)),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.settings, size: 64, color: AppColors.primaryPink),
            SizedBox(height: 16),
            Text(
              '설정 화면',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '앱 설정을 변경하세요!',
              style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
