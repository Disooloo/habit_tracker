import '../repositories/habit_repository.dart';

class DeleteHabit {
  final HabitRepository repository;

  DeleteHabit(this.repository);

  Future<void> call(int id) async {
    await repository.deleteHabit(id);
  }
}


