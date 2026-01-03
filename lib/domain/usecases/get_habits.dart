import '../entities/habit.dart';
import '../repositories/habit_repository.dart';

class GetHabits {
  final HabitRepository repository;

  GetHabits(this.repository);

  Future<List<Habit>> call() async {
    return await repository.getAllHabits();
  }
}


