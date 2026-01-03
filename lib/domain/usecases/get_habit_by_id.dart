import '../entities/habit.dart';
import '../repositories/habit_repository.dart';

class GetHabitById {
  final HabitRepository repository;

  GetHabitById(this.repository);

  Future<Habit?> call(int id) async {
    return await repository.getHabitById(id);
  }
}


