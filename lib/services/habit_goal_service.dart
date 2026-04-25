import 'package:shared_preferences/shared_preferences.dart';

class HabitGoalService {
  static const String _goalPrefix = 'habit_goal_';

  static final Map<String, List<String>> _ruTemplatesByKeyword = {
    'чтен': [
      'Концентрация при чтении 20 минут без отвлечений',
      'Читать быстрее: +5 страниц в день',
      'Читать 30 минут каждый вечер',
      'Понимать материал глубже: конспект после чтения',
    ],
    'книг': [
      'Прочитывать 1 книгу в месяц',
      'Читать каждый день минимум 20 минут',
      'Делать заметки после каждой главы',
    ],
    'спорт': [
      'Тренироваться 3 раза в неделю',
      'Сделать 10000 шагов за день',
      'Увеличивать нагрузку на 5% каждую неделю',
    ],
    'бег': [
      'Бегать 20 минут без остановки',
      'Пробежать 5 км за тренировку',
      'Бегать 3 раза в неделю',
    ],
    'вода': [
      'Выпивать 6 стаканов воды каждый день',
      'Пить воду в начале каждого часа',
      'Всегда держать бутылку воды рядом',
    ],
    'прогул': [
      'Проходить не менее 6000 шагов в день',
      'Делать прогулку минимум 20 минут',
      'Выходить на улицу 2 раза в день',
    ],
    'растяж': [
      'Растягиваться 10 минут утром',
      'Сделать 3 упражнения на мобильность ежедневно',
      'Отмечать растяжку 7 дней подряд',
    ],
    'кур': [
      'Сокращать количество сигарет каждую неделю',
      'Удерживаться от курения 4 часа подряд',
      'Заменять тягу дыханием и водой',
    ],
    'алког': [
      'Провести 7 дней без алкоголя',
      'Выбирать безалкогольные альтернативы на встречах',
      'Сократить поводы употребления вдвое',
    ],
    'глубок': [
      'Работать 45 минут в режиме глубокой концентрации',
      'Сделать 2 сессии deep work в день',
      'Уменьшить отвлечения до 1 за сессию',
    ],
    'слад': [
      'Провести 7 дней без сладкого на ночь',
      'Заменять вечерний десерт на полезный перекус',
      'Ограничить сладкое до 2 порций в неделю',
    ],
    'переед': [
      'Оставлять небольшой запас сытости после еды',
      'Есть медленно не менее 15 минут',
      'Избегать позднего переедания 5 дней подряд',
    ],
    'соцсет': [
      'Не использовать соцсети за 1 час до сна',
      'Сократить экранное время на 20%',
      'Держать 2 окна без телефона в день',
    ],
    'цифров': [
      'Делать цифровой детокс 30 минут ежедневно',
      'Проверять мессенджеры по расписанию 3 раза в день',
      'Отключить лишние уведомления и держать фокус',
    ],
    'коммуник': [
      'Практиковать активное слушание в 1 разговоре в день',
      'Поддерживать контакт с близкими минимум 3 раза в неделю',
      'Говорить спокойно и без резких реакций',
    ],
    'сон': [
      'Спать не менее 8 часов 5 дней подряд',
      'Ложиться до 23:00 всю неделю',
      'Стабилизировать режим сна и подъема',
    ],
    'подъ': [
      'Просыпаться в выбранное время 7 дней подряд',
      'Уменьшить утреннюю сонливость за 2 недели',
      'Закрепить ранний подъем без откладывания будильника',
    ],
    'энерг': [
      'Провести 7 дней без энергетиков',
      'Заменять энергетик водой или чаем',
      'Уменьшить тягу к стимуляторам каждую неделю',
    ],
  };

  static final Map<String, List<String>> _enTemplatesByKeyword = {
    'read': [
      'Read 20 minutes with full focus',
      'Increase speed by +5 pages per day',
      'Read every evening for 30 minutes',
      'Write brief notes after reading',
    ],
    'book': [
      'Finish 1 book per month',
      'Read at least 20 minutes daily',
      'Capture one key insight after each chapter',
    ],
    'sport': [
      'Train 3 times per week',
      'Reach 10,000 steps per day',
      'Increase load by 5% weekly',
    ],
    'run': [
      'Run 20 minutes without stopping',
      'Run 5 km per session',
      'Run 3 times per week',
    ],
    'water': [
      'Drink 6 glasses of water every day',
      'Drink water every hour',
      'Keep a water bottle nearby all day',
    ],
    'walk': [
      'Walk at least 6,000 steps per day',
      'Take a 20-minute walk daily',
      'Go outside twice a day',
    ],
    'stretch': [
      'Stretch for 10 minutes in the morning',
      'Do 3 mobility exercises daily',
      'Keep a 7-day stretching streak',
    ],
    'smok': [
      'Reduce cigarettes week by week',
      'Stay smoke-free for 4 hours blocks',
      'Replace craving with breathing and water',
    ],
    'alco': [
      'Keep 7 alcohol-free days',
      'Choose non-alcohol options at meetings',
      'Cut drinking occasions by half',
    ],
    'deep work': [
      'Work 45 minutes in deep focus mode',
      'Complete 2 deep work sessions daily',
      'Reduce distractions to 1 per session',
    ],
    'sweet': [
      'Keep 7 nights without sweets',
      'Replace late dessert with a healthy snack',
      'Limit sweets to 2 portions per week',
    ],
    'overeat': [
      'Stop eating at comfortable satiety',
      'Eat slowly for at least 15 minutes',
      'Avoid late overeating 5 days in a row',
    ],
    'social': [
      'No social media during the last hour before sleep',
      'Cut screen time by 20%',
      'Have 2 no-phone windows every day',
    ],
    'digital': [
      'Do a 30-minute digital detox daily',
      'Check messengers on schedule 3 times a day',
      'Turn off noisy notifications to keep focus',
    ],
    'communic': [
      'Practice active listening in one conversation daily',
      'Reach out to close people at least 3 times weekly',
      'Communicate calmly without sharp reactions',
    ],
    'sleep': [
      'Sleep at least 8 hours for 5 days in a row',
      'Go to bed before 23:00 all week',
      'Stabilize sleep and wake routine',
    ],
    'wake': [
      'Wake up at your target time for 7 days in a row',
      'Reduce morning grogginess within 2 weeks',
      'Keep early wake-up without snooze',
    ],
    'energy': [
      'Keep 7 days without energy drinks',
      'Replace energy drinks with water or tea',
      'Reduce stimulant cravings week by week',
    ],
  };

  List<String> templatesForHabit(String habitName, String languageCode) {
    final lower = habitName.toLowerCase();
    final result = <String>[];
    final templatesMap = languageCode.startsWith('ru')
        ? _ruTemplatesByKeyword
        : _enTemplatesByKeyword;
    for (final entry in templatesMap.entries) {
      if (lower.contains(entry.key)) {
        result.addAll(entry.value);
      }
    }
    return result;
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
    final lower = goal.toLowerCase();
    final isRu = languageCode.startsWith('ru');
    if (lower.contains('чита') || lower.contains('книг') || lower.contains('read') || lower.contains('book')) {
      return [
        isRu
            ? 'Выберите фиксированное время чтения и одно место без отвлечений'
            : 'Choose a fixed reading time and one distraction-free place',
        isRu
            ? 'Начинайте с 10-15 минут и увеличивайте длительность постепенно'
            : 'Start with 10-15 minutes and increase duration gradually',
        isRu
            ? 'После каждой сессии фиксируйте 1-2 мысли, чтобы закрепить результат'
            : 'After each session write 1-2 insights to reinforce progress',
      ];
    }
    if (lower.contains('концент') || lower.contains('focus')) {
      return [
        isRu
            ? 'Отключите уведомления на время выполнения'
            : 'Disable notifications during focus sessions',
        isRu
            ? 'Работайте короткими отрезками 20-25 минут'
            : 'Work in short 20-25 minute blocks',
        isRu
            ? 'Делайте паузу 3-5 минут и повторяйте цикл'
            : 'Take 3-5 minute breaks and repeat the cycle',
      ];
    }
    if (lower.contains('быстр') || lower.contains('speed')) {
      return [
        isRu
            ? 'Замеряйте текущий темп в начале недели'
            : 'Measure your current pace at the start of each week',
        isRu
            ? 'Увеличивайте план на 5-10% раз в неделю'
            : 'Increase target by 5-10% weekly',
        isRu
            ? 'Фокусируйтесь на регулярности, а не на рекордах'
            : 'Focus on consistency rather than records',
      ];
    }
    return [
      isRu
          ? 'Разбейте цель на маленькие ежедневные шаги'
          : 'Break your goal into small daily steps',
      isRu
          ? 'Запланируйте конкретное время выполнения'
          : 'Schedule a concrete execution time',
      isRu
          ? 'Еженедельно пересматривайте прогресс и корректируйте план'
          : 'Review progress weekly and adjust your plan',
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

