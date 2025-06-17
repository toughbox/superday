import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import '../models/goal.dart';
import '../models/achievement.dart';
import '../services/goal_provider_interface.dart';

class BackupService {
  /// 데이터 내보내기
  Future<bool> exportData(GoalProviderInterface goalProvider) async {
    try {
      // 모든 데이터 수집
      final goals = goalProvider.goals;
      final achievements = goalProvider.achievements;
      
      // JSON 형태로 변환
      final backupData = {
        'version': '1.0',
        'exportDate': DateTime.now().toIso8601String(),
        'goals': goals.map((goal) => goal.toJson()).toList(),
        'achievements': achievements.map((achievement) => achievement.toJson()).toList(),
      };
      
      final jsonString = const JsonEncoder.withIndent('  ').convert(backupData);
      
      // 모바일에서 파일 저장
      return await _saveFileMobile(jsonString);
    } catch (e) {
      print('데이터 내보내기 오류: $e');
      return false;
    }
  }
  
  /// 데이터 가져오기
  Future<bool> importData(String filePath, GoalProviderInterface goalProvider) async {
    try {
      final file = File(filePath);
      final jsonString = await file.readAsString();
      final data = jsonDecode(jsonString) as Map<String, dynamic>;
      
      // 데이터 검증
      if (!_validateBackupData(data)) {
        return false;
      }
      
      // 기존 데이터 백업을 위한 확인 (실제로는 사용자에게 물어봐야 함)
      
      // 목표 데이터 복원
      final goalsData = data['goals'] as List<dynamic>;
      final goals = goalsData.map((goalJson) => Goal.fromJson(goalJson as Map<String, dynamic>)).toList();
      
      // 달성 기록 데이터 복원
      final achievementsData = data['achievements'] as List<dynamic>;
      final achievements = achievementsData.map((achievementJson) => Achievement.fromJson(achievementJson as Map<String, dynamic>)).toList();
      
      // 데이터베이스에 저장 (실제로는 goalProvider를 통해 복원)
      // 이 부분은 goalProvider에 복원 메서드가 있어야 함
      
      return true;
    } catch (e) {
      print('데이터 가져오기 오류: $e');
      return false;
    }
  }
  

  
  /// 모바일에서 파일 저장
  Future<bool> _saveFileMobile(String content) async {
    try {
      final fileName = 'superday_backup_${DateTime.now().millisecondsSinceEpoch}.json';
      
      // 저장 위치 선택
      final filePath = await FilePicker.platform.saveFile(
        dialogTitle: '백업 파일 저장',
        fileName: fileName,
        type: FileType.custom,
        allowedExtensions: ['json'],
      );
      
      if (filePath != null) {
        final file = File(filePath);
        await file.writeAsString(content);
        return true;
      }
      
      return false;
    } catch (e) {
      print('모바일 파일 저장 오류: $e');
      return false;
    }
  }
  
  /// 백업 데이터 검증
  bool _validateBackupData(Map<String, dynamic> data) {
    try {
      // 필수 필드 확인
      if (!data.containsKey('version') || 
          !data.containsKey('goals') || 
          !data.containsKey('achievements')) {
        return false;
      }
      
      // 버전 확인
      final version = data['version'] as String?;
      if (version != '1.0') {
        return false;
      }
      
      // 데이터 타입 확인
      if (data['goals'] is! List || data['achievements'] is! List) {
        return false;
      }
      
      return true;
    } catch (e) {
      return false;
    }
  }
} 