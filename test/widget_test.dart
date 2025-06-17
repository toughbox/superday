// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:superday/main.dart';
import 'package:superday/services/web_goal_provider.dart';

void main() {
  group('하루성공 앱 기본 테스트', () {
    testWidgets('앱 시작 시 홈 화면이 표시되는지 테스트', (WidgetTester tester) async {
      // 앱 빌드 및 프레임 트리거
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (context) => WebGoalProvider(),
          child: const SuperDayApp(),
        ),
      );
      
      // 홈 화면 요소들이 표시되는지 확인
      expect(find.text('오늘의 목표'), findsOneWidget);
      expect(find.byType(BottomNavigationBar), findsOneWidget);
    });

    testWidgets('바텀 네비게이션 탭 전환 테스트', (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (context) => WebGoalProvider(),
          child: const SuperDayApp(),
        ),
      );

      // 달력 탭 클릭
      await tester.tap(find.byIcon(Icons.calendar_month));
      await tester.pump();
      
      // 달력 화면이 표시되는지 확인
      expect(find.text('달력'), findsOneWidget);

      // 히스토리 탭 클릭
      await tester.tap(find.byIcon(Icons.history));
      await tester.pump();
      
      // 히스토리 화면이 표시되는지 확인
      expect(find.text('히스토리'), findsOneWidget);

      // 설정 탭 클릭
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pump();
      
      // 설정 화면이 표시되는지 확인 (AppBar의 설정 텍스트만 확인)
      expect(find.text('설정'), findsAtLeastNWidgets(1));
    });

    testWidgets('목표 추가 버튼이 존재하는지 테스트', (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (context) => WebGoalProvider(),
          child: const SuperDayApp(),
        ),
      );

      // 홈 화면에서 목표 추가 버튼 확인
      expect(find.text('목표 추가'), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });
  });

  group('데이터 모델 테스트', () {
    test('Goal 모델 JSON 변환 테스트', () {
      // Goal 객체 생성 및 JSON 변환 테스트는 별도 파일에서 진행
    });
  });
}
