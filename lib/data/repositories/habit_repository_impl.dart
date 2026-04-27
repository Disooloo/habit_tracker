import 'package:sqflite/sqflite.dart';
import '../../domain/entities/habit.dart';
import '../../domain/entities/habit_tracking.dart';
import '../../domain/repositories/habit_repository.dart';
import '../database/app_database.dart';
import '../models/habit_model.dart';
import '../models/habit_tracking_model.dart';
import '../../core/utils/date_utils.dart';

class HabitRepositoryImpl implements HabitRepository {
  final AppDatabase _database = AppDatabase();

  @override
  Future<int> createHabit(Habit habit) async {
    final db = await _database.database;
    final model = HabitModel.fromEntity(habit);
    final json = model.toJson();
    // Remove id for new records to let database auto-generate it
    json.remove('id');
    return await db.insert('habits', json);
  }

  @override
  Future<List<Habit>> getAllHabits() async {
    final db = await _database.database;
    final List<Map<String, dynamic>> maps = await db.query('habits', orderBy: 'created_at DESC');

    return List.generate(maps.length, (i) {
      return HabitModel.fromJson(maps[i]);
    });
  }

  @override
  Future<Habit?> getHabitById(int id) async {
    final db = await _database.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'habits',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return HabitModel.fromJson(maps.first);
  }

  @override
  Future<void> updateHabit(Habit habit) async {
    final db = await _database.database;
    final model = HabitModel.fromEntity(habit);
    await db.update(
      'habits',
      model.toJson(),
      where: 'id = ?',
      whereArgs: [habit.id],
    );
  }

  @override
  Future<void> deleteHabit(int id) async {
    final db = await _database.database;
    await db.delete('habits', where: 'id = ?', whereArgs: [id]);
    // Tracking entries will be deleted automatically due to CASCADE
  }

  @override
  Future<void> deleteAllHabits() async {
    final db = await _database.database;
    await db.delete('habit_tracking');
    await db.delete('habits');
  }

  @override
  Future<int> getHabitCount() async {
    final db = await _database.database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM habits');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  @override
  Future<void> trackHabit(HabitTracking tracking) async {
    final db = await _database.database;
    final model = HabitTrackingModel.fromEntity(tracking);
    final json = model.toJson();
    // Remove id for new records to let database auto-generate it
    json.remove('id');
    
    // Use INSERT OR REPLACE to handle same-day updates
    await db.insert(
      'habit_tracking',
      json,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> deleteTrackingById(int trackingId) async {
    final db = await _database.database;
    await db.delete(
      'habit_tracking',
      where: 'id = ?',
      whereArgs: [trackingId],
    );
  }

  @override
  Future<List<HabitTracking>> getTrackingByHabitId(int habitId) async {
    final db = await _database.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'habit_tracking',
      where: 'habit_id = ?',
      whereArgs: [habitId],
      orderBy: 'date DESC',
    );

    return List.generate(maps.length, (i) {
      return HabitTrackingModel.fromJson(maps[i]);
    });
  }

  @override
  Future<HabitTracking?> getTrackingByHabitIdAndDate(int habitId, String date) async {
    final db = await _database.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'habit_tracking',
      where: 'habit_id = ? AND date = ?',
      whereArgs: [habitId, date],
    );

    if (maps.isEmpty) return null;
    return HabitTrackingModel.fromJson(maps.first);
  }

  @override
  Future<List<HabitTracking>> getTrackingByDateRange(String startDate, String endDate) async {
    final db = await _database.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'habit_tracking',
      where: 'date >= ? AND date <= ?',
      whereArgs: [startDate, endDate],
      orderBy: 'date DESC',
    );

    return List.generate(maps.length, (i) {
      return HabitTrackingModel.fromJson(maps[i]);
    });
  }

  @override
  Future<Map<String, int>> getTrackingStatsByHabitId(int habitId) async {
    final db = await _database.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT status, COUNT(*) as count
      FROM habit_tracking
      WHERE habit_id = ?
      GROUP BY status
    ''', [habitId]);

    final Map<String, int> stats = {};
    for (var map in maps) {
      stats[map['status'] as String] = map['count'] as int;
    }
    return stats;
  }

  @override
  Future<Map<int, int>> getTrackingByWeekday(int habitId) async {
    final db = await _database.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT 
        CAST(strftime('%w', date) AS INTEGER) as weekday,
        COUNT(*) as count
      FROM habit_tracking
      WHERE habit_id = ? AND status != ?
      GROUP BY weekday
      ORDER BY weekday
    ''', [habitId, 'not_done']);

    final Map<int, int> weekdayStats = {};
    for (var map in maps) {
      // SQLite %w returns 0-6 (Sunday=0), convert to 1-7 (Monday=1)
      int weekday = map['weekday'] as int;
      if (weekday == 0) weekday = 7; // Sunday becomes 7
      weekdayStats[weekday] = map['count'] as int;
    }
    return weekdayStats;
  }

  @override
  Future<int> getDaysWithAttempt(int habitId) async {
    final db = await _database.database;
    final result = await db.rawQuery('''
      SELECT COUNT(DISTINCT date) as count
      FROM habit_tracking
      WHERE habit_id = ? AND status != ?
    ''', [habitId, 'not_done']);
    
    return Sqflite.firstIntValue(result) ?? 0;
  }

  @override
  Future<int> getTotalDays(int habitId) async {
    final habit = await getHabitById(habitId);
    if (habit == null) return 0;

    final now = DateTime.now();
    final createdAt = habit.createdAt;
    final daysSinceCreation = now.difference(createdAt).inDays + 1;
    return daysSinceCreation;
  }

  @override
  Future<int> getComebackCount(int habitId) async {
    // Count how many times user came back after a break (not_done followed by done/partial)
    final db = await _database.database;
    final result = await db.rawQuery('''
      WITH tracking_ordered AS (
        SELECT date, status,
               LAG(status) OVER (ORDER BY date) as prev_status
        FROM habit_tracking
        WHERE habit_id = ?
        ORDER BY date
      )
      SELECT COUNT(*) as count
      FROM tracking_ordered
      WHERE prev_status = ? AND status != ?
    ''', [habitId, 'not_done', 'not_done']);
    
    return Sqflite.firstIntValue(result) ?? 0;
  }
}

