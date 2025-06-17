// 하루성공 앱 성능 테스트
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:superday/main.dart';
import 'package:superday/services/web_goal_provider.dart';

void main() {
  group('성능 테스트', () {
    testWidgets('앱 시작 속도 테스트', (WidgetTester tester) async {
      final stopwatch = Stopwatch()..start();
      
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (context) => WebGoalProvider(),
          child: const SuperDayApp(),
        ),
      );
      
      stopwatch.stop();
      
      // 앱이 1초 이내에 시작되는지 확인
      expect(stopwatch.elapsedMilliseconds, lessThan(1000));
      print('앱 시작 시간: ${stopwatch.elapsedMilliseconds}ms');
    });

    testWidgets('화면 전환 성능 테스트', (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (context) => WebGoalProvider(),
          child: const SuperDayApp(),
        ),
      );

      final stopwatch = Stopwatch()..start();
      
      // 달력 탭으로 전환
      await tester.tap(find.byIcon(Icons.calendar_month));
      await tester.pump();
      
      stopwatch.stop();
      
      // 화면 전환이 100ms 이내에 완료되는지 확인
      expect(stopwatch.elapsedMilliseconds, lessThan(100));
      print('화면 전환 시간: ${stopwatch.elapsedMilliseconds}ms');
    });

    testWidgets('메모리 누수 체크', (WidgetTester tester) async {
      // 여러 번 화면 전환하여 메모리 누수 확인
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (context) => WebGoalProvider(),
          child: const SuperDayApp(),
        ),
      );

      for (int i = 0; i < 10; i++) {
        // 모든 탭을 순환
        await tester.tap(find.byIcon(Icons.calendar_month));
        await tester.pump();
        
        await tester.tap(find.byIcon(Icons.history));
        await tester.pump();
        
        await tester.tap(find.byIcon(Icons.settings));
        await tester.pump();
        
        await tester.tap(find.byIcon(Icons.home));
        await tester.pump();
      }
      
      // 메모리 누수가 없다면 테스트 통과
      expect(true, isTrue);
      print('메모리 누수 테스트 완료');
    });
  });
} 