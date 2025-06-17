import 'dart:async';
import 'dart:html' as html;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  Timer? _notificationTimer;
  bool _isRunning = false;

  /// 권한 요청
  Future<bool> requestPermission() async {
    if (kIsWeb) {
      // 웹에서 알림 권한 요청
      try {
        final permission = await html.Notification.requestPermission();
        return permission == 'granted';
      } catch (e) {
        print('알림 권한 요청 실패: $e');
        return false;
      }
    }
    return true; // 모바일에서는 임시로 true
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

  /// 알림 스케줄링 시작
  Future<void> startNotificationScheduler() async {
    if (_isRunning) return;

    _isRunning = true;

    // 1분마다 체크
    _notificationTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _checkAndSendNotifications();
    });

    print('알림 스케줄러 시작됨');
  }

  /// 알림 스케줄링 중지
  Future<void> stopNotificationScheduler() async {
    _notificationTimer?.cancel();
    _notificationTimer = null;
    _isRunning = false;
    print('알림 스케줄러 중지됨');
  }

  /// 현재 시간 체크하여 알림 발송
  Future<void> _checkAndSendNotifications() async {
    final settings = await getSettings();
    final now = DateTime.now();
    final currentHour = now.hour;
    final currentMinute = now.minute;

    print(
      '🕐 알림 체크: ${currentHour}:${currentMinute.toString().padLeft(2, '0')} - 활성화: ${settings['enabled']}',
    );

    if (!settings['enabled']) return;

    // 매일 리마인더 체크
    if (settings['dailyReminder']) {
      final reminderHour = settings['reminderHour'] ?? 9;
      final reminderMinute = settings['reminderMinute'] ?? 0;

      print(
        '  - 매일 리마인더: ${settings['dailyReminder']} (설정시간: $reminderHour:${reminderMinute.toString().padLeft(2, '0')})',
      );

      if (currentHour == reminderHour && currentMinute == reminderMinute) {
        print('  ✅ 매일 리마인더 발송!');
        await _showWebNotification(
          '🎯 목표 설정 시간입니다!',
          '오늘의 목표를 설정해보세요. 작은 성공이 큰 변화를 만듭니다!',
        );
      }
    }

    // 격려 메시지 체크 (오후 2시)
    if (settings['encouragement'] && currentHour == 14 && currentMinute == 0) {
      print('  ✅ 격려 메시지 발송!');
      final messages = [
        '💪 목표 달성하고 계신가요? 조금만 더 화이팅!',
        '⚡ 포기하지 마세요! 성공이 코앞에 있어요!',
        '🌟 당신은 할 수 있어요! 오늘도 멋지게!',
        '🚀 목표를 향해 한 걸음 더 나아가세요!',
      ];
      final message = messages[now.day % messages.length];

      await _showWebNotification('💪 목표 달성 체크!', message);
    }

    // 저녁 리뷰 체크 (저녁 8시)
    if (settings['eveningReview'] && currentHour == 20 && currentMinute == 0) {
      print('  ✅ 저녁 리뷰 발송!');
      await _showWebNotification(
        '🌙 하루 마무리 시간',
        '오늘의 목표는 어떠셨나요? 달성 여부를 확인해보세요!',
      );
    }
  }

  /// 웹 알림 표시
  Future<void> _showWebNotification(String title, String body) async {
    if (kIsWeb) {
      try {
        final notification = html.Notification(
          title,
          body: body,
          icon: '/favicon.png',
        );

        notification.onClick.listen((event) {
          // html.window.focus(); // 웹에서 지원하지 않는 메서드
          notification.close();
        });

        // 5초 후 자동으로 닫기
        Timer(const Duration(seconds: 5), () {
          notification.close();
        });

        print('알림 발송: $title - $body');
      } catch (e) {
        print('알림 발송 실패: $e');
      }
    } else {
      // 모바일에서는 로그만
      print('알림: $title - $body');
    }
  }

  /// 매일 리마인더 스케줄링
  Future<void> scheduleDailyReminder(TimeOfDay time) async {
    print('매일 리마인더 설정: ${time.hour}:${time.minute.toString().padLeft(2, '0')}');

    if (_isRunning) {
      await stopNotificationScheduler();
      await startNotificationScheduler();
    }
  }

  /// 격려 메시지 스케줄링
  Future<void> scheduleEncouragementMessage() async {
    print('격려 메시지 알림 설정');
  }

  /// 저녁 리뷰 스케줄링
  Future<void> scheduleEveningReview() async {
    print('저녁 리뷰 알림 설정');
  }

  /// 모든 알림 취소
  Future<void> cancelAll() async {
    await stopNotificationScheduler();
    print('모든 알림 취소');
  }

  /// 특정 알림 취소
  Future<void> cancel(int id) async {
    print('알림 $id 취소');
  }
}
