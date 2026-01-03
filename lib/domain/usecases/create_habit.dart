import '../entities/habit.dart';
import '../repositories/habit_repository.dart';
import '../../core/constants/app_constants.dart';

class CreateHabit {
  final HabitRepository repository;

  CreateHabit(this.repository);

  Future<Result> call(Habit habit) async {
    try {
      // Check free limit if needed (this will be checked in the UI layer with subscription service)
      final id = await repository.createHabit(habit);
      return Success(id);
    } catch (e) {
      return Error(e.toString());
    }
  }
}

abstract class Result {}

class Success extends Result {
  final int id;
  Success(this.id);
}

class Error extends Result {
  final String message;
  Error(this.message);
}


