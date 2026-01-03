import '../repositories/habit_repository.dart';
import '../../core/utils/date_utils.dart';

class GetStatistics {
  final HabitRepository repository;

  GetStatistics(this.repository);

  Future<StatisticsResult> call(int habitId) async {
    try {
      final daysWithAttempt = await repository.getDaysWithAttempt(habitId);
      final totalDays = await repository.getTotalDays(habitId);
      final weekdayStats = await repository.getTrackingByWeekday(habitId);
      final comebackCount = await repository.getComebackCount(habitId);

      // Find best day of week
      int? bestWeekday;
      int maxCount = 0;
      weekdayStats.forEach((weekday, count) {
        if (count > maxCount) {
          maxCount = count;
          bestWeekday = weekday;
        }
      });

      return StatisticsResult(
        daysWithAttempt: daysWithAttempt,
        totalDays: totalDays,
        bestWeekday: bestWeekday,
        comebackCount: comebackCount,
        weekdayStats: weekdayStats,
      );
    } catch (e) {
      return StatisticsResult(
        daysWithAttempt: 0,
        totalDays: 0,
        bestWeekday: null,
        comebackCount: 0,
        weekdayStats: {},
        error: e.toString(),
      );
    }
  }
}

class StatisticsResult {
  final int daysWithAttempt;
  final int totalDays;
  final int? bestWeekday; // 1-7 (Monday=1, Sunday=7)
  final int comebackCount;
  final Map<int, int> weekdayStats;
  final String? error;

  StatisticsResult({
    required this.daysWithAttempt,
    required this.totalDays,
    this.bestWeekday,
    required this.comebackCount,
    required this.weekdayStats,
    this.error,
  });

  double get attemptPercentage {
    if (totalDays == 0) return 0.0;
    return (daysWithAttempt / totalDays) * 100;
  }

  String? get bestDayName {
    if (bestWeekday == null) return null;
    final date = DateTime.now();
    final testDate = date.add(Duration(days: bestWeekday! - date.weekday));
    return DateUtils.getDayOfWeekName(testDate);
  }
}


