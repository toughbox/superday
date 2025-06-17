import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:file_picker/file_picker.dart';
import '../constants/colors.dart';
import '../constants/strings.dart';
import '../services/goal_provider_interface.dart';
import '../services/notification_service.dart';
import '../services/backup_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final NotificationService _notificationService = NotificationService();
  final BackupService _backupService = BackupService();
  
  // 설정 상태들
  bool _isDarkMode = false;
  bool _notificationsEnabled = false;
  bool _dailyReminder = true;
  bool _encouragementMessage = true;
  bool _eveningReview = true;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 9, minute: 0);
  
  // 앱 정보
  String _appVersion = '';
  String _appBuildNumber = '';
  
  @override
  void initState() {
    super.initState();
    _loadSettings();
    _loadAppInfo();
  }

  /// 설정 로드
  Future<void> _loadSettings() async {
    final settings = await _notificationService.getSettings();
    setState(() {
      _notificationsEnabled = settings['enabled'] ?? false;
      _dailyReminder = settings['dailyReminder'] ?? true;
      _encouragementMessage = settings['encouragement'] ?? true;
      _eveningReview = settings['eveningReview'] ?? true;
      final hour = settings['reminderHour'] ?? 9;
      final minute = settings['reminderMinute'] ?? 0;
      _reminderTime = TimeOfDay(hour: hour, minute: minute);
      
      // 다크모드는 시스템 테마를 따라감 (추후 SharedPreferences로 저장 가능)
      _isDarkMode = Theme.of(context).brightness == Brightness.dark;
    });
  }

  /// 앱 정보 로드
  Future<void> _loadAppInfo() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _appVersion = packageInfo.version;
      _appBuildNumber = packageInfo.buildNumber;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          '설정',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.primaryPink,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 테마 설정
          _buildSectionCard(
            '테마 설정',
            [
              _buildSwitchTile(
                icon: Icons.dark_mode,
                title: '다크 모드',
                subtitle: '어두운 테마 사용',
                value: _isDarkMode,
                onChanged: _toggleDarkMode,
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // 알림 설정
          _buildSectionCard(
            '알림 설정',
            [
              _buildSwitchTile(
                icon: Icons.notifications,
                title: '알림 허용',
                subtitle: '목표 리마인더 및 격려 메시지',
                value: _notificationsEnabled,
                onChanged: _toggleNotifications,
              ),
              if (_notificationsEnabled) ...[
                const Divider(height: 1),
                _buildTimeTile(
                  icon: Icons.access_time,
                  title: '리마인더 시간',
                  subtitle: '매일 목표 설정 알림 시간',
                  time: _reminderTime,
                  onChanged: _changeReminderTime,
                ),
                const Divider(height: 1),
                _buildSwitchTile(
                  icon: Icons.alarm,
                  title: '매일 리마인더',
                  subtitle: '목표 설정 알림',
                  value: _dailyReminder,
                  onChanged: (value) => _updateNotificationSetting('dailyReminder', value),
                ),
                const Divider(height: 1),
                _buildSwitchTile(
                  icon: Icons.favorite,
                  title: '격려 메시지',
                  subtitle: '목표 달성 응원 알림',
                  value: _encouragementMessage,
                  onChanged: (value) => _updateNotificationSetting('encouragement', value),
                ),
                const Divider(height: 1),
                _buildSwitchTile(
                  icon: Icons.nightlight_round,
                  title: '저녁 리뷰',
                  subtitle: '하루 목표 확인 알림',
                  value: _eveningReview,
                  onChanged: (value) => _updateNotificationSetting('eveningReview', value),
                ),
              ],
            ],
          ),
          
          const SizedBox(height: 16),
          
          // 데이터 관리
          _buildSectionCard(
            '데이터 관리',
            [
              _buildActionTile(
                icon: Icons.backup,
                title: '데이터 백업',
                subtitle: '목표 데이터를 파일로 내보내기',
                onTap: _exportData,
              ),
              const Divider(height: 1),
              _buildActionTile(
                icon: Icons.restore,
                title: '데이터 복원',
                subtitle: '백업 파일에서 데이터 가져오기',
                onTap: _importData,
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // 앱 정보
          _buildSectionCard(
            '앱 정보',
            [
              _buildInfoTile(
                icon: Icons.info,
                title: '버전',
                subtitle: '$_appVersion ($_appBuildNumber)',
              ),
              const Divider(height: 1),
              _buildActionTile(
                icon: Icons.description,
                title: '개인정보처리방침',
                subtitle: '개인정보 보호 정책',
                onTap: _openPrivacyPolicy,
              ),
              const Divider(height: 1),
              _buildActionTile(
                icon: Icons.email,
                title: '문의하기',
                subtitle: '개발자에게 문의',
                onTap: _contactDeveloper,
              ),
              const Divider(height: 1),
              _buildActionTile(
                icon: Icons.star,
                title: '앱 평가하기',
                subtitle: '스토어에서 평가하기',
                onTap: _rateApp,
              ),
            ],
          ),
          
          const SizedBox(height: 32),
          
          // 하단 로고
          Center(
            child: Column(
              children: [
                Icon(
                  Icons.celebration,
                  size: 48,
                  color: AppColors.primaryPink.withOpacity(0.5),
                ),
                const SizedBox(height: 8),
                Text(
                  AppStrings.appName,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryPink,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  AppStrings.appDescription,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 섹션 카드 위젯
  Widget _buildSectionCard(String title, List<Widget> children) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          ...children,
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  /// 스위치 타일 위젯
  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.primary,
      ),
    );
  }

  /// 시간 설정 타일 위젯
  Widget _buildTimeTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required TimeOfDay time,
    required ValueChanged<TimeOfDay> onChanged,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Text(
        time.format(context),
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
      ),
      onTap: () async {
        final newTime = await showTimePicker(
          context: context,
          initialTime: time,
        );
        if (newTime != null) {
          onChanged(newTime);
        }
      },
    );
  }

  /// 액션 타일 위젯
  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  /// 정보 타일 위젯
  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title),
      subtitle: Text(subtitle),
    );
  }

  /// 다크모드 토글
  void _toggleDarkMode(bool value) {
    setState(() {
      _isDarkMode = value;
    });
    // TODO: 테마 변경 로직 구현
    _showSnackBar('다크모드는 추후 업데이트에서 지원됩니다');
  }

  /// 알림 토글
  Future<void> _toggleNotifications(bool value) async {
    if (value) {
      final hasPermission = await _notificationService.requestPermission();
      if (!hasPermission) {
        _showSnackBar('알림 권한이 필요합니다. 설정에서 허용해주세요.');
        return;
      }
    }
    
    setState(() {
      _notificationsEnabled = value;
    });
    
    await _notificationService.setEnabled(value);
    
    if (value) {
      await _scheduleNotifications();
      _showSnackBar('알림이 활성화되었습니다');
    } else {
      await _notificationService.cancelAll();
      _showSnackBar('알림이 비활성화되었습니다');
    }
  }

  /// 리마인더 시간 변경
  Future<void> _changeReminderTime(TimeOfDay newTime) async {
    setState(() {
      _reminderTime = newTime;
    });
    
    await _notificationService.setReminderTime(newTime.hour, newTime.minute);
    
    if (_notificationsEnabled) {
      await _scheduleNotifications();
      _showSnackBar('리마인더 시간이 변경되었습니다');
    }
  }

  /// 알림 설정 업데이트
  Future<void> _updateNotificationSetting(String key, bool value) async {
    setState(() {
      switch (key) {
        case 'dailyReminder':
          _dailyReminder = value;
          break;
        case 'encouragement':
          _encouragementMessage = value;
          break;
        case 'eveningReview':
          _eveningReview = value;
          break;
      }
    });
    
    await _notificationService.updateSetting(key, value);
    
    if (_notificationsEnabled) {
      await _scheduleNotifications();
    }
  }

  /// 알림 스케줄링
  Future<void> _scheduleNotifications() async {
    await _notificationService.cancelAll();
    
    if (_dailyReminder) {
      await _notificationService.scheduleDailyReminder(_reminderTime);
    }
    
    if (_encouragementMessage) {
      await _notificationService.scheduleEncouragementMessage();
    }
    
    if (_eveningReview) {
      await _notificationService.scheduleEveningReview();
    }
  }

  /// 데이터 내보내기
  Future<void> _exportData() async {
    try {
      final goalProvider = context.read<GoalProviderInterface>();
      final success = await _backupService.exportData(goalProvider);
      
      if (success) {
        _showSnackBar('데이터가 성공적으로 내보내졌습니다');
      } else {
        _showSnackBar('데이터 내보내기에 실패했습니다');
      }
    } catch (e) {
      _showSnackBar('오류가 발생했습니다: ${e.toString()}');
    }
  }

  /// 데이터 가져오기
  Future<void> _importData() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );
      
      if (result != null && result.files.single.path != null) {
        final goalProvider = context.read<GoalProviderInterface>();
        final success = await _backupService.importData(
          result.files.single.path!,
          goalProvider,
        );
        
        if (success) {
          _showSnackBar('데이터가 성공적으로 복원되었습니다');
          await goalProvider.refresh();
        } else {
          _showSnackBar('데이터 복원에 실패했습니다');
        }
      }
    } catch (e) {
      _showSnackBar('오류가 발생했습니다: ${e.toString()}');
    }
  }

  /// 개인정보처리방침 열기
  Future<void> _openPrivacyPolicy() async {
    const url = 'https://www.example.com/privacy-policy';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      _showSnackBar('링크를 열 수 없습니다');
    }
  }

  /// 개발자 문의
  Future<void> _contactDeveloper() async {
    const email = 'mailto:developer@example.com?subject=하루성공 앱 문의';
    if (await canLaunchUrl(Uri.parse(email))) {
      await launchUrl(Uri.parse(email));
    } else {
      _showSnackBar('이메일 앱을 열 수 없습니다');
    }
  }

  /// 앱 평가하기
  Future<void> _rateApp() async {
    const url = 'https://play.google.com/store/apps/details?id=com.example.superday';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      _showSnackBar('스토어를 열 수 없습니다');
    }
  }

  /// 스낵바 표시
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
} 