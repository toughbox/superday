import 'package:flutter/material.dart';
import '../models/goal.dart';
import '../constants/colors.dart';

class GoalItem extends StatefulWidget {
  final Goal goal;
  final VoidCallback? onTap;
  final VoidCallback? onComplete;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const GoalItem({
    super.key,
    required this.goal,
    this.onTap,
    this.onComplete,
    this.onEdit,
    this.onDelete,
  });

  @override
  State<GoalItem> createState() => _GoalItemState();
}

class _GoalItemState extends State<GoalItem> with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _checkController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _checkAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _checkController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
    _checkAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _checkController, curve: Curves.elasticOut),
    );

    if (widget.goal.isCompleted) {
      _checkController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _checkController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(GoalItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.goal.isCompleted != oldWidget.goal.isCompleted) {
      if (widget.goal.isCompleted) {
        _checkController.forward();
      } else {
        _checkController.reverse();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color:
                widget.goal.isCompleted
                    ? AppColors.success.withOpacity(0.3)
                    : AppColors.border,
            width: widget.goal.isCompleted ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color:
                  widget.goal.isCompleted
                      ? AppColors.success.withOpacity(0.1)
                      : AppColors.shadow,
              blurRadius: widget.goal.isCompleted ? 12 : 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            onTapDown: (_) => _scaleController.forward(),
            onTapUp: (_) => _scaleController.reverse(),
            onTapCancel: () => _scaleController.reverse(),
            borderRadius: BorderRadius.circular(16),
                          child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // 첫 번째 줄: 체크박스 - 목표 - 트로피 - 삭제버튼
                  Row(
                    children: [
                      // 완료 체크박스
                      GestureDetector(
                        onTap: widget.onComplete,
                        child: AnimatedBuilder(
                          animation: _checkAnimation,
                          builder: (context, child) {
                            return Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color:
                                    widget.goal.isCompleted
                                        ? AppColors.success
                                        : AppColors.surface,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color:
                                      widget.goal.isCompleted
                                          ? AppColors.success
                                          : AppColors.border,
                                  width: 2,
                                ),
                              ),
                              child:
                                  widget.goal.isCompleted
                                      ? Transform.scale(
                                        scale: _checkAnimation.value,
                                        child: const Icon(
                                          Icons.check,
                                          size: 16,
                                          color: AppColors.textOnPrimary,
                                        ),
                                      )
                                      : null,
                            );
                          },
                        ),
                      ),

                      const SizedBox(width: 16),

                      // 목표 제목
                      Expanded(
                        child: Text(
                          widget.goal.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color:
                                widget.goal.isCompleted
                                    ? AppColors.textSecondary
                                    : AppColors.textPrimary,
                            decoration:
                                widget.goal.isCompleted
                                    ? TextDecoration.lineThrough
                                    : null,
                            decorationColor: AppColors.textSecondary,
                          ),
                        ),
                      ),

                      // 완료된 목표의 트로피
                      if (widget.goal.isCompleted)
                        Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: ScaleTransition(
                            scale: _checkAnimation,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: AppColors.successGradient,
                                ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.success.withOpacity(0.3),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.emoji_events,
                                size: 18,
                                color: AppColors.textOnPrimary,
                              ),
                            ),
                          ),
                        ),
                      
                      // 수정 버튼 (완료되지 않은 목표만)
                      if (!widget.goal.isCompleted && widget.onEdit != null)
                        Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: AppColors.surfaceVariant,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: widget.onEdit,
                                borderRadius: BorderRadius.circular(10),
                                child: const Icon(
                                  Icons.edit_rounded,
                                  size: 18,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ),
                        ),

                      // 삭제 버튼
                      if (widget.onDelete != null)
                        Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: AppColors.danger.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: widget.onDelete,
                                borderRadius: BorderRadius.circular(10),
                                child: const Icon(
                                  Icons.delete_outline_rounded,
                                  size: 18,
                                  color: AppColors.danger,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // 두 번째 줄: 목표설정일과 달성일시 (좌측정렬)
                  Row(
                    children: [
                      // 목표 설정 날짜
                      Icon(
                        Icons.schedule_rounded,
                        size: 14,
                        color: AppColors.textTertiary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '목표 설정: ${widget.goal.formattedDate}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textTertiary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      
                      // 달성일시 (완료된 목표만)
                      if (widget.goal.isCompleted && widget.goal.completedDate != null) ...[
                        const SizedBox(width: 16),
                        Icon(
                          Icons.check_circle_rounded,
                          size: 14,
                          color: AppColors.success,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '달성: ${widget.goal.formattedCompletedDate}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.success,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
