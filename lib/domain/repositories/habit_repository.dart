import '../entities/habit.dart';
import '../entities/habit_tracking.dart';

abstract class HabitRepository {
  Future<int> createHabit(Habit habit);
  Future<List<Habit>> getAllHabits();
  Future<Habit?> getHabitById(int id);
  Future<void> updateHabit(Habit habit);
  Future<void> deleteHabit(int id);
  Future<void> deleteAllHabits();
  Future<int> getHabitCount();

  // Tracking methods
  Future<void> trackHabit(HabitTracking tracking);
  Future<void> deleteTrackingById(int trackingId);
  Future<List<HabitTracking>> getTrackingByHabitId(int habitId);
  Future<HabitTracking?> getTrackingByHabitIdAndDate(int habitId, String date);
  Future<List<HabitTracking>> getTrackingByDateRange(String startDate, String endDate);

  // Statistics methods
  Future<Map<String, int>> getTrackingStatsByHabitId(int habitId);
  Future<Map<int, int>> getTrackingByWeekday(int habitId);
  Future<int> getDaysWithAttempt(int habitId);
  Future<int> getTotalDays(int habitId);
  Future<int> getComebackCount(int habitId);
}


