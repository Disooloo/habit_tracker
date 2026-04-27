class Habit {
  final int id;
  final String name;
  final String minimalAction;
  final String frequency; // 'daily' or 'weekly'
  final String? reminderTime; // HH:mm format or null
  final List<int>? reminderDays; // 1-7 (Mon-Sun), null means every day
  final DateTime createdAt;
  
  // Количественные цели (например, 3 стакана воды)
  final String? goalType; // 'quantity', 'time', or null (simple)
  final int? targetValue; // Целевое значение (например, 3 стакана, 60 минут)
  final String? unit; // Единица измерения (например, 'стаканов', 'минут')

  const Habit({
    required this.id,
    required this.name,
    required this.minimalAction,
    required this.frequency,
    this.reminderTime,
    this.reminderDays,
    required this.createdAt,
    this.goalType,
    this.targetValue,
    this.unit,
  });

  Habit copyWith({
    int? id,
    String? name,
    String? minimalAction,
    String? frequency,
    String? reminderTime,
    List<int>? reminderDays,
    DateTime? createdAt,
    String? goalType,
    int? targetValue,
    String? unit,
  }) {
    return Habit(
      id: id ?? this.id,
      name: name ?? this.name,
      minimalAction: minimalAction ?? this.minimalAction,
      frequency: frequency ?? this.frequency,
      reminderTime: reminderTime ?? this.reminderTime,
      reminderDays: reminderDays ?? this.reminderDays,
      createdAt: createdAt ?? this.createdAt,
      goalType: goalType ?? this.goalType,
      targetValue: targetValue ?? this.targetValue,
      unit: unit ?? this.unit,
    );
  }
}


