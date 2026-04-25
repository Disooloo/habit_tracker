import 'package:shared_preferences/shared_preferences.dart';

class HabitGoalService {
  static const String _goalPrefix = 'habit_goal_';

  static const List<String> readingGoalTemplates = [
    'Концентрация при чтении 20 минут без отвлечений',
    'Читать быстрее: +5 страниц в день',
    'Читать 30 минут каждый вечер',
    'Понимать материал глубже: конспект после чтения',
  ];

  Future<String?> getGoal(int habitId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('$_goalPrefix$habitId');
  }

  Future<void> saveGoal(int habitId, String goal) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_goalPrefix$habitId', goal.trim());
  }

  List<String> buildPlanForGoal(String goal) {
    final lower = goal.toLowerCase();
    if (lower.contains('чита') || lower.contains('книг')) {
      return [
        'Выберите фиксированное время чтения и одно место без отвлечений',
        'Начинайте с 10-15 минут и увеличивайте длительность постепенно',
        'После каждой сессии фиксируйте 1-2 мысли, чтобы закрепить результат',
      ];
    }
    if (lower.contains('концент')) {
      return [
        'Отключите уведомления на время выполнения',
        'Работайте короткими отрезками 20-25 минут',
        'Делайте паузу 3-5 минут и повторяйте цикл',
      ];
    }
    if (lower.contains('быстр')) {
      return [
        'Замеряйте текущий темп в начале недели',
        'Увеличивайте план на 5-10% раз в неделю',
        'Фокусируйтесь на регулярности, а не на рекордах',
      ];
    }
    return [
      'Разбейте цель на маленькие ежедневные шаги',
      'Запланируйте конкретное время выполнения',
      'Еженедельно пересматривайте прогресс и корректируйте план',
    ];
  }

  Future<Map<int, String>> exportAllGoals() async {
    final prefs = await SharedPreferences.getInstance();
    final result = <int, String>{};
    for (final key in prefs.getKeys()) {
      if (!key.startsWith(_goalPrefix)) continue;
      final id = int.tryParse(key.substring(_goalPrefix.length));
      final value = prefs.getString(key);
      if (id != null && value != null && value.isNotEmpty) {
        result[id] = value;
      }
    }
    return result;
  }

  Future<void> clearAllGoals() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((k) => k.startsWith(_goalPrefix)).toList();
    for (final key in keys) {
      await prefs.remove(key);
    }
  }
}

