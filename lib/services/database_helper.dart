import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/goal.dart';
import '../models/achievement.dart';

/// SQLite 데이터베이스 관리 클래스
class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  /// 데이터베이스 인스턴스 getter
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// 데이터베이스 초기화
  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'superday.db');

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDatabase,
      onUpgrade: _upgradeDatabase,
    );
  }

  /// 데이터베이스 테이블 생성
  Future<void> _createDatabase(Database db, int version) async {
    // goals 테이블 생성
    await db.execute('''
      CREATE TABLE goals (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        created_date TEXT NOT NULL,
        is_completed INTEGER DEFAULT 0,
        completed_date TEXT
      )
    ''');

    // achievements 테이블 생성
    await db.execute('''
      CREATE TABLE achievements (
        id TEXT PRIMARY KEY,
        goal_id TEXT NOT NULL,
        achieved_date TEXT NOT NULL,
        celebration_message TEXT NOT NULL,
        FOREIGN KEY (goal_id) REFERENCES goals (id) ON DELETE CASCADE
      )
    ''');

    // 인덱스 생성 (검색 성능 향상)
    await db.execute('''
      CREATE INDEX idx_goals_created_date ON goals (created_date)
    ''');

    await db.execute('''
      CREATE INDEX idx_achievements_achieved_date ON achievements (achieved_date)
    ''');

    await db.execute('''
      CREATE INDEX idx_achievements_goal_id ON achievements (goal_id)
    ''');
  }

  /// 데이터베이스 업그레이드
  Future<void> _upgradeDatabase(Database db, int oldVersion, int newVersion) async {
    // 날짜 필터링 문제 해결을 위해 기존 테이블 삭제하고 재생성
    if (oldVersion < 2) {
      // 기존 테이블 삭제
      await db.execute('DROP TABLE IF EXISTS achievements');
      await db.execute('DROP TABLE IF EXISTS goals');
      
      // 새로운 테이블 생성
      await _createDatabase(db, newVersion);
    }
  }

  /// 목표 저장
  Future<int> insertGoal(Goal goal) async {
    final db = await database;
    return await db.insert(
      'goals',
      goal.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// 목표 업데이트
  Future<int> updateGoal(Goal goal) async {
    final db = await database;
    return await db.update(
      'goals',
      goal.toJson(),
      where: 'id = ?',
      whereArgs: [goal.id],
    );
  }

  /// 목표 삭제
  Future<int> deleteGoal(String goalId) async {
    final db = await database;
    return await db.delete(
      'goals',
      where: 'id = ?',
      whereArgs: [goalId],
    );
  }

  /// 모든 목표 조회
  Future<List<Goal>> getAllGoals() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'goals',
      orderBy: 'created_date DESC',
    );

    return List.generate(maps.length, (i) {
      return Goal.fromJson(maps[i]);
    });
  }

  /// 특정 날짜의 목표 조회
  Future<List<Goal>> getGoalsByDate(DateTime date) async {
    final db = await database;
    
    // 해당 날짜의 시작과 끝 시간 계산
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
    
    final List<Map<String, dynamic>> maps = await db.query(
      'goals',
      where: 'created_date >= ? AND created_date <= ?',
      whereArgs: [startOfDay.toIso8601String(), endOfDay.toIso8601String()],
      orderBy: 'created_date DESC',
    );

    return List.generate(maps.length, (i) {
      return Goal.fromJson(maps[i]);
    });
  }

  /// 날짜 범위로 목표 조회
  Future<List<Goal>> getGoalsByDateRange(DateTime startDate, DateTime endDate) async {
    final db = await database;
    
    // 시작 날짜의 00:00:00 부터 종료 날짜의 23:59:59 까지
    final startOfDay = DateTime(startDate.year, startDate.month, startDate.day);
    final endOfDay = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59, 999);
    
    final List<Map<String, dynamic>> maps = await db.query(
      'goals',
      where: 'created_date >= ? AND created_date <= ?',
      whereArgs: [startOfDay.toIso8601String(), endOfDay.toIso8601String()],
      orderBy: 'created_date DESC',
    );

    return List.generate(maps.length, (i) {
      return Goal.fromJson(maps[i]);
    });
  }

  /// 달성 기록 저장
  Future<int> insertAchievement(Achievement achievement) async {
    final db = await database;
    return await db.insert(
      'achievements',
      achievement.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// 모든 달성 기록 조회
  Future<List<Achievement>> getAllAchievements() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'achievements',
      orderBy: 'achieved_date DESC',
    );

    return List.generate(maps.length, (i) {
      return Achievement.fromJson(maps[i]);
    });
  }

  /// 특정 목표의 달성 기록 조회
  Future<Achievement?> getAchievementByGoalId(String goalId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'achievements',
      where: 'goal_id = ?',
      whereArgs: [goalId],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return Achievement.fromJson(maps.first);
    }
    return null;
  }

  /// 데이터베이스 닫기
  Future<void> closeDatabase() async {
    final db = await database;
    await db.close();
  }

  /// 데이터베이스 삭제 (개발/테스트용)
  Future<void> deleteDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'superday.db');
    await databaseFactory.deleteDatabase(path);
    _database = null;
  }
} 