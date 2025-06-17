import 'package:intl/intl.dart';

/// 목표 달성 기록 모델
class Achievement {
  final String id;
  final String goalId;
  final DateTime achievedDate;
  final String celebrationMessage;

  Achievement({
    required this.id,
    required this.goalId,
    required this.achievedDate,
    required this.celebrationMessage,
  });

  /// JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'goal_id': goalId,
      'achieved_date': achievedDate.toIso8601String(),
      'celebration_message': celebrationMessage,
    };
  }

  /// JSON에서 Achievement 객체 생성
  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'] as String,
      goalId: json['goal_id'] as String,
      achievedDate: DateTime.parse(json['achieved_date'] as String),
      celebrationMessage: json['celebration_message'] as String,
    );
  }

  /// 달성 날짜 포맷팅 (MM/dd HH:mm 형식)
  String get formattedAchievedDate {
    return DateFormat('MM/dd HH:mm').format(achievedDate);
  }

  /// 달성 날짜가 오늘인지 확인
  bool get isToday {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final achievedDay = DateTime(
      achievedDate.year,
      achievedDate.month,
      achievedDate.day,
    );
    return today == achievedDay;
  }

  /// 달성 날짜가 이번 주인지 확인
  bool get isThisWeek {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 6));
    
    return achievedDate.isAfter(weekStart) && 
           achievedDate.isBefore(weekEnd.add(const Duration(days: 1)));
  }

  @override
  String toString() {
    return 'Achievement(id: $id, goalId: $goalId, achievedDate: $achievedDate, message: $celebrationMessage)';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Achievement && 
      runtimeType == other.runtimeType && 
      id == other.id;

  @override
  int get hashCode => id.hashCode;
} 