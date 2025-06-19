import 'package:flutter/material.dart';
import '../constants/colors.dart';

class AppIcon extends StatelessWidget {
  final double size;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const AppIcon({
    super.key,
    this.size = 60.0,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? AppColors.primary;
    final fgColor = foregroundColor ?? Colors.white;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(size * 0.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: size * 0.1,
            offset: Offset(0, size * 0.05),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 심플한 달력 배경
          Positioned(
            top: size * 0.2,
            child: Container(
              width: size * 0.75,
              height: size * 0.6,
              decoration: BoxDecoration(
                color: fgColor,
                borderRadius: BorderRadius.circular(size * 0.1),
                border: Border.all(color: Colors.grey.shade300, width: 2),
              ),
            ),
          ),

          // 달력 헤더 (더 두껍게)
          Positioned(
            top: size * 0.2,
            child: Container(
              width: size * 0.75,
              height: size * 0.15,
              decoration: BoxDecoration(
                color: AppColors.primaryLavender.withOpacity(0.8),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(size * 0.1),
                  topRight: Radius.circular(size * 0.1),
                ),
              ),
            ),
          ),

          // 심플한 날짜 점들 (상단)
          Positioned(
            top: size * 0.42,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildSimpleDot(size),
                SizedBox(width: size * 0.08),
                _buildSimpleDot(size),
                SizedBox(width: size * 0.08),
                _buildSimpleDot(size),
                SizedBox(width: size * 0.08),
                _buildSimpleDot(size),
              ],
            ),
          ),

          // 큰 트로피 (날짜 영역 중앙)
          Positioned(top: size * 0.44, child: _buildLargeTrophy(size)),

          // 심플한 날짜 점들 (하단)
          Positioned(
            top: size * 0.68,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildSimpleDot(size),
                SizedBox(width: size * 0.08),
                _buildSimpleDot(size),
                SizedBox(width: size * 0.08),
                _buildSimpleDot(size),
                SizedBox(width: size * 0.08),
                _buildSimpleDot(size),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleDot(double size) {
    return Container(
      width: size * 0.04,
      height: size * 0.04,
      decoration: BoxDecoration(
        color: Colors.grey.shade400,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildLargeTrophy(double size) {
    return Container(
      width: size * 0.25,
      height: size * 0.25,
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.amber.shade200, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withOpacity(0.3),
            blurRadius: size * 0.05,
            offset: Offset(0, size * 0.02),
          ),
        ],
      ),
      child: Icon(
        Icons.emoji_events,
        size: size * 0.18,
        color: Colors.amber.shade600,
      ),
    );
  }
}
