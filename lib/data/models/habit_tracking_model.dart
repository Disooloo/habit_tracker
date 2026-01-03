import '../../domain/entities/habit_tracking.dart';
import '../../core/utils/date_utils.dart';

class HabitTrackingModel extends HabitTracking {
  const HabitTrackingModel({
    required super.id,
    required super.habitId,
    required super.date,
    required super.status,
    required super.timestamp,
    super.currentValue,
  });

  factory HabitTrackingModel.fromJson(Map<String, dynamic> json) {
    return HabitTrackingModel(
      id: json['id'] as int,
      habitId: json['habit_id'] as int,
      date: json['date'] as String,
      status: json['status'] as String,
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp'] as int),
      currentValue: json['current_value'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'habit_id': habitId,
      'date': date,
      'status': status,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'current_value': currentValue,
    };
  }

  factory HabitTrackingModel.fromEntity(HabitTracking tracking) {
    return HabitTrackingModel(
      id: tracking.id,
      habitId: tracking.habitId,
      date: tracking.date,
      status: tracking.status,
      timestamp: tracking.timestamp,
      currentValue: tracking.currentValue,
    );
  }
}


