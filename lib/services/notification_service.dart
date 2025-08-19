import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'dart:io' show Platform;
import 'goal_provider.dart';

/// 로컬 알림 서비스
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  
  /// 알림 초기화
  Future<void> initialize() async {
    // 타임존 초기화
    tz.initializeTimeZones();
    
    // Android 초기화 설정
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    
    // iOS 초기화 설정
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    
    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
    
    // 권한 요청
    await _requestPermissions();
    
    // 매일 20시 알림 스케줄링
    await scheduleDailyGoalReminder();
  }
  
  /// 알림 권한 요청
  Future<void> _requestPermissions() async {
    if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _notifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      
      await androidImplementation?.requestNotificationsPermission();
      await androidImplementation?.requestExactAlarmsPermission();
    } else if (Platform.isIOS) {
      final IOSFlutterLocalNotificationsPlugin? iosImplementation =
          _notifications.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
      
      await iosImplementation?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }
  
  /// 알림 탭 처리
  void _onNotificationTapped(NotificationResponse response) {
    // 알림 탭 시 앱 열기 (필요시 특정 화면으로 이동)
    print('알림 탭됨: ${response.payload}');
  }
  
  /// 매일 20시 목표 확인 알림 스케줄링
  Future<void> scheduleDailyGoalReminder() async {
    // 기존 알림 취소
    await _notifications.cancel(1);
    
    // 오늘 20시 시간 계산
    final now = DateTime.now();
    var scheduledDate = DateTime(now.year, now.month, now.day, 20, 0);
    
    // 이미 20시가 지났다면 내일 20시로 설정
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'goal_reminder',
      '목표 리마인더',
      channelDescription: '매일 20시에 목표 달성 여부를 확인합니다',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );
    
    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    
    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    
    await _notifications.zonedSchedule(
      1, // 알림 ID
      '목표 확인 시간이에요! 📝',
      '오늘의 목표를 모두 달성하셨나요?',
      tz.TZDateTime.from(scheduledDate, tz.local),
      details,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time, // 매일 같은 시간에 반복
      payload: 'goal_reminder',
    );
    
    print('매일 20시 목표 리마인더 알림이 설정되었습니다.');
  }
  
  /// 목표 미완료 알림 전송
  Future<void> sendIncompleteGoalNotification(int incompleteCount, int totalCount) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'incomplete_goals',
      '미완료 목표 알림',
      channelDescription: '완료하지 못한 목표가 있을 때 알려줍니다',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      icon: '@mipmap/ic_launcher',
    );
    
    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    
    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    
    String title = '아직 완료하지 못한 목표가 있어요! 💪';
    String body = '오늘 $totalCount개 목표 중 $incompleteCount개가 남았습니다. 조금만 더 힘내세요!';
    
    await _notifications.show(
      2, // 알림 ID
      title,
      body,
      details,
      payload: 'incomplete_goals',
    );
  }
  
  /// 모든 목표 완료 축하 알림
  Future<void> sendAllGoalsCompletedNotification() async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'all_completed',
      '목표 완료 축하',
      channelDescription: '모든 목표를 완료했을 때 축하 메시지를 보냅니다',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      icon: '@mipmap/ic_launcher',
    );
    
    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    
    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    
    await _notifications.show(
      3, // 알림 ID
      '🎉 축하합니다!',
      '오늘의 모든 목표를 완료하셨네요! 정말 대단해요!',
      details,
      payload: 'all_completed',
    );
  }
  
  /// 20시에 목표 달성 여부 확인 및 알림
  Future<void> checkAndNotifyGoalStatus(GoalProvider goalProvider) async {
    await goalProvider.loadTodayGoals();
    
    final totalCount = goalProvider.todayTotalCount;
    final completedCount = goalProvider.todayCompletedCount;
    final incompleteCount = totalCount - completedCount;
    
    if (totalCount == 0) {
      // 오늘 목표가 없는 경우
      await _notifications.show(
        4,
        '목표를 설정해보세요! 🎯',
        '오늘은 아직 목표를 설정하지 않으셨네요. 작은 목표라도 세워보는 건 어떨까요?',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'no_goals',
            '목표 설정 안내',
            channelDescription: '목표가 없을 때 설정을 안내합니다',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
      );
    } else if (incompleteCount > 0) {
      // 미완료 목표가 있는 경우
      await sendIncompleteGoalNotification(incompleteCount, totalCount);
    } else {
      // 모든 목표 완료
      await sendAllGoalsCompletedNotification();
    }
  }
  

  
  /// 모든 알림 취소
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }
  
  /// 특정 알림 취소
  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }
}
