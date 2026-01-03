class HabitTracking {
  final int id;
  final int habitId;
  final String date; // YYYY-MM-DD format
  final String status; // 'done', 'partial', or 'not_done'
  final DateTime timestamp;
  final int? currentValue; // Текущее значение для количественных/временных целей

  const HabitTracking({
    required this.id,
    required this.habitId,
    required this.date,
    required this.status,
    required this.timestamp,
    this.currentValue,
  });

  HabitTracking copyWith({
    int? id,
    int? habitId,
    String? date,
    String? status,
    DateTime? timestamp,
    int? currentValue,
  }) {
    return HabitTracking(
      id: id ?? this.id,
      habitId: habitId ?? this.habitId,
      date: date ?? this.date,
      status: status ?? this.status,
      timestamp: timestamp ?? this.timestamp,
      currentValue: currentValue ?? this.currentValue,
    );
  }
}


