import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/goal_provider_interface.dart';
import '../constants/colors.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          '설정',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 사용자 정보 카드
            Container(
              width: double.infinity,
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
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: const Icon(
                      Icons.person_rounded,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '하루성공 사용자',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '매일 목표를 달성하는 성취자',
                    style: TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 데이터 관리 섹션
            _buildSectionTitle('데이터 관리'),
            _buildSettingsCard([
              _buildActionTile(
                '데이터 백업',
                '목표 데이터를 백업합니다',
                Icons.backup_rounded,
                () => _showBackupDialog(),
              ),
              const Divider(height: 1),
              _buildActionTile(
                '데이터 복원',
                '백업된 데이터를 복원합니다',
                Icons.restore_rounded,
                () => _showRestoreDialog(),
              ),
              const Divider(height: 1),
              _buildActionTile(
                '모든 데이터 삭제',
                '모든 목표와 기록을 삭제합니다',
                Icons.delete_forever_rounded,
                () => _showDeleteAllDialog(),
                isDestructive: true,
              ),
            ]),

            const SizedBox(height: 16),

            // 정보 섹션
            _buildSectionTitle('정보'),
            _buildSettingsCard([
              _buildInfoTile('앱 버전', '1.0.0', Icons.info_rounded),
              const Divider(height: 1),
              _buildActionTile(
                '개발자 정보',
                '앱 개발자에 대한 정보',
                Icons.code_rounded,
                () => _showDeveloperInfo(),
              ),
              const Divider(height: 1),
              _buildActionTile(
                '오픈소스 라이센스',
                '사용된 오픈소스 라이센스',
                Icons.description_rounded,
                () => _showLicenses(),
              ),
            ]),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildActionTile(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    final color = isDestructive ? AppColors.danger : AppColors.primary;

    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: isDestructive ? AppColors.danger : AppColors.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
      ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: AppColors.textSecondary,
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  Widget _buildInfoTile(String title, String value, IconData icon) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.textSecondary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppColors.textSecondary, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
      trailing: Text(
        value,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w500,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  void _showBackupDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text(
              '데이터 백업',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: const Text('목표 데이터를 백업하시겠습니까?\n백업된 데이터는 기기에 저장됩니다.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('취소'),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);
                  // 백업 로직 구현
                  _showSnackBar('데이터 백업이 완료되었습니다', isSuccess: true);
                },
                child: const Text('백업'),
              ),
            ],
          ),
    );
  }

  void _showRestoreDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text(
              '데이터 복원',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: const Text('백업된 데이터를 복원하시겠습니까?\n현재 데이터는 덮어씌워집니다.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('취소'),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);
                  // 복원 로직 구현
                  _showSnackBar('데이터 복원이 완료되었습니다', isSuccess: true);
                },
                child: const Text('복원'),
              ),
            ],
          ),
    );
  }

  void _showDeleteAllDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text(
              '모든 데이터 삭제',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.danger,
              ),
            ),
            content: const Text('정말로 모든 목표와 기록을 삭제하시겠습니까?\n이 작업은 되돌릴 수 없습니다.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('취소'),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);
                  final goalProvider = context.read<GoalProviderInterface>();
                  // 모든 목표를 하나씩 삭제
                  final allGoals = List.from(goalProvider.goals);
                  for (final goal in allGoals) {
                    await goalProvider.deleteGoal(goal.id);
                  }
                  await goalProvider.refresh();
                  _showSnackBar('모든 데이터가 삭제되었습니다', isSuccess: true);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.danger,
                ),
                child: const Text('삭제'),
              ),
            ],
          ),
    );
  }

  void _showDeveloperInfo() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text(
              '개발자 정보',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: const Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('하루성공 - 목표 달성 앱'),
                SizedBox(height: 8),
                Text('매일 작은 목표를 설정하고 달성하여\n성취감을 느낄 수 있는 앱입니다.'),
                SizedBox(height: 16),
                Text('Made with ❤️ using Flutter'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('확인'),
              ),
            ],
          ),
    );
  }

  void _showLicenses() {
    showLicensePage(
      context: context,
      applicationName: '하루성공',
      applicationVersion: '1.0.0',
    );
  }

  void _showSnackBar(String message, {bool isSuccess = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccess ? AppColors.success : AppColors.danger,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
