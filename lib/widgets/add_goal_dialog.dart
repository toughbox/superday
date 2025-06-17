import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/goal.dart';
import '../services/goal_provider_interface.dart';
import '../constants/colors.dart';
import '../constants/strings.dart';

class AddGoalDialog extends StatefulWidget {
  final Goal? goal; // 수정할 때 전달되는 기존 목표

  const AddGoalDialog({
    super.key,
    this.goal,
  });

  @override
  State<AddGoalDialog> createState() => _AddGoalDialogState();
}

class _AddGoalDialogState extends State<AddGoalDialog> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // 수정 모드인 경우 기존 제목 설정
    if (widget.goal != null) {
      _controller.text = widget.goal!.title;
    }
    
    // 다이얼로그 열릴 때 자동으로 포커스
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditMode = widget.goal != null;
    
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Text(
        isEditMode ? '목표 수정' : AppStrings.addGoal,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _controller,
            focusNode: _focusNode,
            maxLength: 50,
            decoration: InputDecoration(
              hintText: AppStrings.goalInputHint,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.primary),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.primary, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            onSubmitted: (_) => _handleSubmit(),
          ),
          const SizedBox(height: 8),
          Text(
            '💡 구체적이고 달성 가능한 목표를 설정해보세요',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text(
            '취소',
            style: TextStyle(color: Colors.grey),
          ),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _handleSubmit,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(isEditMode ? '수정' : '추가'),
        ),
      ],
    );
  }

  void _handleSubmit() async {
    final title = _controller.text.trim();
    
    if (title.isEmpty) {
      _showSnackBar(AppStrings.goalEmpty);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final goalProvider = context.read<GoalProviderInterface>();
      bool success;

      if (widget.goal != null) {
        // 수정 모드
        success = await goalProvider.updateGoal(widget.goal!.id, title);
      } else {
        // 추가 모드
        success = await goalProvider.addGoal(title);
      }

      if (success && mounted) {
        Navigator.pop(context);
        _showSnackBar(
          widget.goal != null 
              ? '목표가 수정되었습니다' 
              : '목표가 추가되었습니다',
          isSuccess: true,
        );
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('오류가 발생했습니다: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showSnackBar(String message, {bool isSuccess = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccess ? AppColors.success : Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }
} 