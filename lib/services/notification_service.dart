import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  /// 권한 요청 (현재는 간단한 구현)
  Future<bool> requestPermission() async {
    // 실제 구현에서는 flutter_local_notifications 사용
    return true; // 임시로 항상 true 반환
  }

  /// 설정 저장
  Future<void> setEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', enabled);
  }

  /// 리마인더 시간 설정
  Future<void> setReminderTime(int hour, int minute) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('reminder_hour', hour);
    await prefs.setInt('reminder_minute', minute);
  }

  /// 개별 설정 업데이트
  Future<void> updateSetting(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notification_$key', value);
  }

  /// 설정 가져오기
  Future<Map<String, dynamic>> getSettings() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'enabled': prefs.getBool('notifications_enabled') ?? false,
      'dailyReminder': prefs.getBool('notification_dailyReminder') ?? true,
      'encouragement': prefs.getBool('notification_encouragement') ?? true,
      'eveningReview': prefs.getBool('notification_eveningReview') ?? true,
      'reminderHour': prefs.getInt('reminder_hour') ?? 9,
      'reminderMinute': prefs.getInt('reminder_minute') ?? 0,
    };
  }

  /// 매일 리마인더 스케줄링
  Future<void> scheduleDailyReminder(TimeOfDay time) async {
    // 실제 구현에서는 flutter_local_notifications 사용
    print('매일 리마인더 설정: ${time.format(null as BuildContext)}');
  }

  /// 격려 메시지 스케줄링
  Future<void> scheduleEncouragementMessage() async {
    // 실제 구현에서는 flutter_local_notifications 사용
    print('격려 메시지 알림 설정');
  }

  /// 저녁 리뷰 스케줄링
  Future<void> scheduleEveningReview() async {
    // 실제 구현에서는 flutter_local_notifications 사용
    print('저녁 리뷰 알림 설정');
  }

  /// 모든 알림 취소
  Future<void> cancelAll() async {
    // 실제 구현에서는 flutter_local_notifications 사용
    print('모든 알림 취소');
  }

  /// 특정 알림 취소
  Future<void> cancel(int id) async {
    // 실제 구현에서는 flutter_local_notifications 사용
    print('알림 $id 취소');
  }
} 