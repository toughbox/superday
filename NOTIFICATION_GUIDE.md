# 🔔 20시 목표 미완료 알림 기능

## 📋 구현된 기능

### 1. 자동 알림 스케줄링
- **매일 20시**에 자동으로 목표 달성 여부를 확인
- 앱이 백그라운드에 있어도 알림 전송
- 기기 재부팅 후에도 자동으로 알림 스케줄 복원

### 2. 목표 상태별 알림
- **미완료 목표가 있는 경우**: "아직 완료하지 못한 목표가 있어요! 💪"
- **모든 목표 완료**: "🎉 축하합니다! 오늘의 모든 목표를 완료하셨네요!"
- **목표가 없는 경우**: "목표를 설정해보세요! 🎯"

### 3. 테스트 기능
- **설정 화면**에서 알림 기능 테스트 가능
- 즉시 알림 테스트 (5초 후 전송)
- 현재 목표 상태 확인 및 알림 전송

## 🛠️ 기술적 구현

### 사용된 패키지
```yaml
dependencies:
  flutter_local_notifications: ^17.2.2  # 로컬 알림
  timezone: ^0.9.4                      # 타임존 처리
```

### 주요 클래스
- `NotificationService`: 알림 관리 싱글톤 클래스
- 매일 20시 반복 알림 스케줄링
- 목표 상태 체크 및 알림 전송

### 권한 설정
#### Android (android/app/src/main/AndroidManifest.xml)
```xml
<!-- 알림 권한 -->
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
<uses-permission android:name="android.permission.VIBRATE" />
<uses-permission android:name="android.permission.WAKE_LOCK" />
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM" />
<uses-permission android:name="android.permission.USE_EXACT_ALARM" />
```

#### iOS (ios/Runner/Info.plist)
```xml
<!-- 백그라운드 모드 -->
<key>UIBackgroundModes</key>
<array>
    <string>background-processing</string>
    <string>background-fetch</string>
</array>

<!-- 알림 권한 설명 -->
<key>NSUserNotificationsUsageDescription</key>
<string>매일 목표 달성을 확인하고 동기부여 메시지를 보내기 위해 알림 권한이 필요합니다.</string>
```

## 🚀 사용 방법

### 1. 자동 설정
앱을 처음 실행하면 자동으로:
- 알림 권한 요청
- 매일 20시 알림 스케줄링

### 2. 테스트 방법
1. 앱 실행 → 하단 탭 → **설정**
2. **알림 설정** 섹션에서:
   - **알림 테스트**: 5초 후 테스트 알림 받기
   - **목표 확인 테스트**: 현재 목표 상태 확인 후 알림

### 3. 실제 사용
- 매일 목표를 설정하고 사용
- 20시가 되면 자동으로 목표 달성 여부 확인
- 미완료 목표가 있으면 동기부여 알림 수신

## 📱 지원 플랫폼
- ✅ **Android** (API 21+)
- ✅ **iOS** (iOS 10+)
- ❌ **Web** (로컬 알림 미지원)

## ⚡ 주요 특징

### 1. 스마트 알림
```dart
// 목표 상태에 따른 맞춤형 알림
if (totalCount == 0) {
    // 목표 설정 안내
} else if (incompleteCount > 0) {
    // 미완료 목표 알림
} else {
    // 완료 축하 알림
}
```

### 2. 매일 반복
```dart
// 매일 20시에 반복 실행
await _notifications.zonedSchedule(
  1,
  '목표 확인 시간이에요! 📝',
  '오늘의 목표를 모두 달성하셨나요?',
  scheduledDate,
  details,
  matchDateTimeComponents: DateTimeComponents.time, // 매일 반복
);
```

### 3. 백그라운드 동작
- 앱이 종료되어도 알림 전송
- 기기 재부팅 후 자동 복원
- 배터리 최적화와 관계없이 동작

## 🔧 문제 해결

### 알림이 오지 않는 경우
1. **권한 확인**: 설정 → 앱 → 알림 권한 허용
2. **배터리 최적화**: 앱을 배터리 최적화에서 제외
3. **자동 시작**: 앱 자동 시작 허용 (일부 제조사)

### Android 특화 설정
```kotlin
// 정확한 알람 권한 (Android 12+)
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM" />
```

### iOS 특화 설정
```swift
// 백그라운드 앱 새로고침 허용
Settings → General → Background App Refresh → SuperDay
```

## 📊 알림 통계
- **알림 ID 1**: 매일 20시 목표 확인
- **알림 ID 2**: 미완료 목표 알림
- **알림 ID 3**: 완료 축하 알림
- **알림 ID 4**: 목표 설정 안내
- **알림 ID 99**: 테스트 알림

## 🎯 향후 개선 사항
- [ ] 알림 시간 사용자 설정 가능
- [ ] 다양한 동기부여 메시지 추가
- [ ] 주간/월간 달성률 알림
- [ ] 연속 달성일 기록 알림
- [ ] 사용자별 알림 선호도 설정

---

## 💡 개발자 노트
이 기능은 사용자가 매일 목표를 달성할 수 있도록 돕는 핵심 기능입니다. 20시라는 시간은 하루를 마무리하고 내일을 준비하는 시점으로, 목표 달성을 위한 마지막 기회를 제공합니다.

**핵심 아이디어**: 강압적이지 않은 부드러운 리마인더로 사용자의 동기부여를 높이는 것이 목표입니다.
