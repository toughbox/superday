import 'package:intl/intl.dart';

/// 목표 데이터 모델
class Goal {
  final String id;
  final String title;
  final DateTime createdDate;
  final bool isCompleted;
  final DateTime? completedDate;

  Goal({
    required this.id,
    required this.title,
    required this.createdDate,
    this.isCompleted = false,
    this.completedDate,
  });

  /// JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'created_date': createdDate.toIso8601String(),
      'is_completed': isCompleted ? 1 : 0,
      'completed_date': completedDate?.toIso8601String(),
    };
  }

  /// JSON에서 Goal 객체 생성
  factory Goal.fromJson(Map<String, dynamic> json) {
    return Goal(
      id: json['id'] as String,
      title: json['title'] as String,
      createdDate: DateTime.parse(json['created_date'] as String),
      isCompleted: (json['is_completed'] as int) == 1,
      completedDate: json['completed_date'] != null
          ? DateTime.parse(json['completed_date'] as String)
          : null,
    );
  }

  /// 목표 완료 처리
  Goal copyWithCompleted() {
    return Goal(
      id: id,
      title: title,
      createdDate: createdDate,
      isCompleted: true,
      completedDate: DateTime.now(),
    );
  }

  /// 목표 수정
  Goal copyWith({
    String? title,
    bool? isCompleted,
    DateTime? completedDate,
  }) {
    return Goal(
      id: id,
      title: title ?? this.title,
      createdDate: createdDate,
      isCompleted: isCompleted ?? this.isCompleted,
      completedDate: completedDate ?? this.completedDate,
    );
  }

  /// 생성된 날짜가 오늘인지 확인
  bool get isToday {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final goalDate = DateTime(
      createdDate.year,
      createdDate.month,
      createdDate.day,
    );
    return today == goalDate;
  }

  /// 날짜 포맷팅 (MM/dd 형식)
  String get formattedDate {
    return DateFormat('MM/dd').format(createdDate);
  }

  /// 완료 날짜 포맷팅
  String get formattedCompletedDate {
    if (completedDate == null) return '';
    return DateFormat('MM/dd HH:mm').format(completedDate!);
  }

  @override
  String toString() {
    return 'Goal(id: $id, title: $title, isCompleted: $isCompleted, createdDate: $createdDate)';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Goal && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
} 