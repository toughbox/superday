import 'package:flutter/material.dart';
import '../models/goal.dart';
import '../constants/colors.dart';
import 'package:intl/intl.dart';

class GoalDetailDialog extends StatelessWidget {
  final Goal goal;
  final VoidCallback? onComplete;

  const GoalDetailDialog({
    super.key,
    required this.goal,
    this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    // 완료일이 오늘인지 여부 계산 (지난 목표의 축하 문구 비노출을 위해 사용)
    final DateTime? completedAt = goal.completedDate;
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    final bool completedToday = completedAt != null &&
        DateTime(completedAt.year, completedAt.month, completedAt.day) == today;
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 500),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 헤더 - 상태 아이콘과 닫기 버튼
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: goal.isCompleted 
                            ? AppColors.success.withOpacity(0.15)
                            : AppColors.primary.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        goal.isCompleted 
                            ? Icons.check_circle_rounded 
                            : Icons.flag_rounded,
                        color: goal.isCompleted 
                            ? AppColors.success 
                            : AppColors.primary,
                        size: 28,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(
                        Icons.close_rounded,
                        color: AppColors.textSecondary,
                      ),
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.surfaceVariant,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // 상태 레이블
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: goal.isCompleted 
                        ? AppColors.success.withOpacity(0.1)
                        : AppColors.warning.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: goal.isCompleted 
                          ? AppColors.success.withOpacity(0.3)
                          : AppColors.warning.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    goal.isCompleted ? '✅ 완료됨' : '⏳ 진행 중',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: goal.isCompleted 
                          ? AppColors.success 
                          : AppColors.warning,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // 목표 제목
                Text(
                  '목표 내용',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.border,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    goal.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                      height: 1.4,
                      decoration: goal.isCompleted 
                          ? TextDecoration.lineThrough 
                          : null,
                      decorationColor: AppColors.textSecondary,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // 세부 정보 섹션
                Text(
                  '세부 정보',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 12),

                // 생성 날짜
                _buildDetailRow(
                  icon: Icons.schedule_rounded,
                  iconColor: AppColors.primary,
                  label: '목표 설정일',
                  value: _getDetailedDate(goal.createdDate),
                ),

                const SizedBox(height: 12),

                // 완료 날짜 (완료된 경우에만)
                if (goal.isCompleted && goal.completedDate != null) ...[
                  _buildDetailRow(
                    icon: Icons.check_circle_rounded,
                    iconColor: AppColors.success,
                    label: '달성일시',
                    value: _getDetailedDate(goal.completedDate!),
                  ),
                  const SizedBox(height: 12),
                ],

                // 소요 시간 섹션 제거

                // 목표 타입
                _buildDetailRow(
                  icon: Icons.today_rounded,
                  iconColor: goal.isToday ? AppColors.success : AppColors.textTertiary,
                  label: '목표 유형',
                  value: goal.isToday ? '오늘의 목표' : '이전 목표',
                ),

                const SizedBox(height: 24),

                // 하단 액션: 완료되지 않은 '오늘 목표'만 완료 버튼 노출
                if (!goal.isCompleted && goal.isToday) ...[
                  // 완료 버튼
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: onComplete != null ? () {
                        onComplete!();
                        Navigator.of(context).pop();
                      } : null,
                      icon: const Icon(
                        Icons.check_circle_rounded,
                        size: 20,
                      ),
                      label: const Text(
                        '목표 완료하기',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // 안내 메시지
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.lightbulb_rounded,
                          color: AppColors.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            '또는 홈화면에서 체크박스를 클릭해도 완료됩니다',
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                // 완료된 목표 축하 메시지: 오직 '오늘 완료'한 경우에만 노출
                if (goal.isCompleted && completedToday) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.success.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.celebration_rounded,
                          color: AppColors.success,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            '축하합니다! 목표를 달성하셨네요! 🎉',
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.success,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 16,
            color: iconColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textTertiary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getDetailedDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDate = DateTime(date.year, date.month, date.day);
    
    final formatter = DateFormat('yyyy년 MM월 dd일 HH:mm');
    String formattedDate = formatter.format(date);
    
    if (targetDate == today) {
      formattedDate += ' • 오늘';
    } else if (targetDate == today.subtract(const Duration(days: 1))) {
      formattedDate += ' • 어제';
    } else if (targetDate.isAfter(today.subtract(const Duration(days: 7)))) {
      final daysAgo = today.difference(targetDate).inDays;
      formattedDate += ' • ${daysAgo}일 전';
    }
    
    return formattedDate;
  }

  // 소요 시간 계산 함수 제거
}