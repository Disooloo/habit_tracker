import 'package:shared_preferences/shared_preferences.dart';

class HabitGoalService {
  static const String _goalPrefix = 'habit_goal_';

  static final Map<String, List<String>> _ruTemplatesByKeyword = {
    // Good habits
    'чтен': [
      'Читать 20 минут без отвлечений 5 дней в неделю',
      'Завершить 1 книгу за 30 дней с коротким конспектом',
      'Читать 10 страниц перед сном каждый день',
      'Разбирать 1 идею из книги и применять ее в течение недели',
    ],
    'спорт': [
      'Тренироваться 3 раза в неделю минимум по 30 минут',
      'Сделать 10 тренировок за месяц без пропусков подряд более 2 дней',
      'Повышать нагрузку на 5% раз в 2 недели',
      'Укрепить выносливость: 40 минут активности в одном темпе',
    ],
    'бег': [
      'Пробегать 3 км 3 раза в неделю',
      'Увеличить дистанцию до 5 км за 6 недель',
      'Поддерживать пульс в комфортной зоне 25 минут',
      'Сделать 12 пробежек в месяц без длинных перерывов',
    ],
    'вода': [
      'Выпивать 6-8 стаканов воды ежедневно',
      'Выпивать 1 стакан воды в первые 15 минут после пробуждения',
      'Держать бутылку воды рядом в течение рабочего дня',
      'Снизить сладкие напитки до 1 порции в неделю',
    ],
    'сон': [
      'Ложиться до 23:30 минимум 5 дней в неделю',
      'Спать 7.5-8 часов в среднем за неделю',
      'Убрать экран за 40 минут до сна каждый вечер',
      'Просыпаться в стабильное время с разбросом не более 30 минут',
    ],
    'медитац': [
      'Медитировать 10 минут 5 дней в неделю',
      'Сделать 14 дней подряд хотя бы по 5 минут практики',
      'Добавить короткую практику дыхания после стресса',
      'Держать суммарно 120 минут медитации в месяц',
    ],
    // Quit habits
    'кур': [
      'Снизить количество сигарет на 20% за 2 недели',
      'Прожить 7 дней без курения после 18:00',
      'Закрепить 30 дней без сигарет',
      'Заменять каждый импульс к курению 2 минутами дыхания',
    ],
    'алког': [
      'Сделать 21 день без алкоголя',
      'Ограничить употребление до 1 повода в неделю',
      'Заменять алкоголь на безалкогольные альтернативы на встречах',
      'Убрать спонтанные покупки алкоголя на месяц',
    ],
    'слад': [
      'Не есть сладкое после ужина 14 дней подряд',
      'Ограничить сладкое до 2 порций в неделю',
      'Заменять десерт фруктом или йогуртом 5 дней в неделю',
      'Снизить добавленный сахар до выбранного дневного лимита',
    ],
    'соцсет': [
      'Сократить соцсети до 40 минут в день',
      'Не открывать соцсети в первый час после пробуждения',
      'Сделать 2 окна фокуса без телефона по 45 минут в день',
      'Проводить 1 день в неделю с минимальным экранным временем',
    ],
    'энерг': [
      'Отказаться от энергетиков на 30 дней',
      'Заменить энергетик водой или чаем каждый раз при тяге',
      'Снизить кофеин после 14:00 до нуля',
      'Поддерживать энергию через сон и активность вместо стимуляторов',
    ],
  };

  static final Map<String, List<String>> _enTemplatesByKeyword = {
    'read': [
      'Read 20 focused minutes at least 5 days per week',
      'Finish 1 book in 30 days with short notes',
      'Read 10 pages before sleep every day',
      'Apply one key idea from reading each week',
    ],
    'sport': [
      'Train 3 times per week for at least 30 minutes',
      'Complete 10 workouts per month with no long breaks',
      'Increase training load by 5% every 2 weeks',
      'Build endurance with 40 minutes of steady activity',
    ],
    'run': [
      'Run 3 km, 3 times per week',
      'Grow to 5 km distance within 6 weeks',
      'Keep a comfortable heart-rate zone for 25 minutes',
      'Complete 12 runs in a month consistently',
    ],
    'water': [
      'Drink 6-8 glasses of water every day',
      'Drink water within 15 minutes after waking up',
      'Keep a water bottle visible during work hours',
      'Reduce sugary drinks to one serving per week',
    ],
    'sleep': [
      'Go to bed before 11:30 PM at least 5 days a week',
      'Average 7.5-8 hours of sleep per week',
      'No screen time 40 minutes before sleep',
      'Keep wake-up time within a 30-minute window',
    ],
    'meditat': [
      'Meditate 10 minutes at least 5 days per week',
      'Keep a 14-day streak with at least 5 minutes daily',
      'Use a short breathing reset after stress',
      'Reach 120 minutes of meditation per month',
    ],
    'smok': [
      'Reduce cigarettes by 20% within 2 weeks',
      'Stay smoke-free after 6 PM for 7 straight days',
      'Build a 30-day smoke-free streak',
      'Replace each craving with 2 minutes of breathing',
    ],
    'alco': [
      'Stay alcohol-free for 21 days',
      'Limit drinking to one occasion per week',
      'Choose non-alcoholic alternatives at social events',
      'Remove impulsive alcohol purchases for one month',
    ],
    'sweet': [
      'No sweets after dinner for 14 days',
      'Limit sweets to 2 portions per week',
      'Replace dessert with fruit/yogurt 5 days weekly',
      'Keep added sugar under your daily target',
    ],
    'social': [
      'Limit social media to 40 minutes per day',
      'No social media in the first hour after waking',
      'Do 2 phone-free focus blocks of 45 minutes daily',
      'Keep one low-screen day every week',
    ],
    'energy': [
      'Quit energy drinks for 30 days',
      'Replace energy drinks with water or tea',
      'Keep caffeine intake after 2 PM at zero',
      'Support energy with sleep and movement, not stimulants',
    ],
  };

  List<String> templatesForHabit(String habitName, String languageCode) {
    final lower = habitName.toLowerCase();
    final map = languageCode.startsWith('ru')
        ? _ruTemplatesByKeyword
        : _enTemplatesByKeyword;

    final result = <String>[];
    for (final entry in map.entries) {
      if (lower.contains(entry.key)) {
        result.addAll(entry.value);
      }
    }

    if (result.isEmpty) {
      return languageCode.startsWith('ru')
          ? const [
              'Стабильно выполнять привычку 5 дней в неделю',
              'Удерживать минимальный шаг каждый день без пропусков более 1 дня',
              'Поддерживать прогресс 30 дней и пересмотреть цель',
              'Делать короткий итог по привычке в конце недели',
            ]
          : const [
              'Keep the habit 5 days per week consistently',
              'Maintain a minimum daily step without long gaps',
              'Sustain progress for 30 days and review target',
              'Write a short weekly reflection on progress',
            ];
    }

    return result.take(4).toList();
  }

  Future<String?> getGoal(int habitId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('$_goalPrefix$habitId');
  }

  Future<void> saveGoal(int habitId, String goal) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_goalPrefix$habitId', goal.trim());
  }

  List<String> buildPlanForGoal(String goal, String languageCode) {
    final isRu = languageCode.startsWith('ru');
    return [
      isRu
          ? 'Определи точное время и место выполнения (когда и где).'
          : 'Define exact execution time and place (when and where).',
      isRu
          ? 'Начни с минимального шага и повышай нагрузку постепенно.'
          : 'Start from a minimum step and increase load gradually.',
      isRu
          ? 'Отслеживай результат ежедневно, даже если шаг был маленьким.'
          : 'Track progress daily, even when the step is small.',
      isRu
          ? 'Раз в неделю проверяй прогресс и корректируй цель.'
          : 'Review progress weekly and adjust the goal.',
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
