import '../entities/habit_tracking.dart';
import '../repositories/habit_repository.dart';
import '../../core/utils/date_utils.dart';

class TrackHabit {
  final HabitRepository repository;

  TrackHabit(this.repository);

  Future<void> call({
    required int habitId,
    required String status, // 'done', 'partial', or 'not_done'
    int? currentValue, // Текущее значение для количественных/временных целей
  }) async {
    final today = DateUtils.today();
    final now = DateTime.now();

    // Check if tracking already exists for today
    final existing = await repository.getTrackingByHabitIdAndDate(habitId, today);

    final tracking = existing != null
        ? existing.copyWith(
            status: status,
            timestamp: now,
            currentValue: currentValue ?? existing.currentValue,
          )
        : HabitTracking(
            id: 0, // Will be auto-generated
            habitId: habitId,
            date: today,
            status: status,
            timestamp: now,
            currentValue: currentValue,
          );

    await repository.trackHabit(tracking);
  }
}


