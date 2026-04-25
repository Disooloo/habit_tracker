class HabitSuggestion {
  final String name;
  final String minimalAction;
  final String category;
  final String emoji;
  final String why;
  final String habitKind; // build or quit
  final String frequency; // daily or weekly
  final String? goalType; // null, quantity, time
  final int? targetValue;
  final String? unit;
  final String tip;

  const HabitSuggestion({
    required this.name,
    required this.minimalAction,
    required this.category,
    required this.emoji,
    required this.why,
    required this.habitKind,
    required this.frequency,
    this.goalType,
    this.targetValue,
    this.unit,
    required this.tip,
  });
}

class HabitSuggestions {
  static const List<HabitSuggestion> all = [
    // Полезные привычки
    HabitSuggestion(
      name: 'Глубокая работа',
      minimalAction: '10 минут без отвлечений',
      category: 'Продуктивность',
      emoji: '🧠',
      why: 'Снимает барьер старта',
      habitKind: 'build',
      frequency: 'daily_multi',
      goalType: 'time',
      targetValue: 25,
      unit: 'минут',
      tip: 'Отключите уведомления на 25 минут и начните с одной задачи.',
    ),
    HabitSuggestion(
      name: 'Чтение книги',
      minimalAction: '1 страница',
      category: 'Саморазвитие',
      emoji: '📚',
      why: 'Постепенно растет концентрация',
      habitKind: 'build',
      frequency: 'daily_multi',
      goalType: 'quantity',
      targetValue: 10,
      unit: null,
      tip: 'Держите книгу рядом с местом отдыха.',
    ),
    HabitSuggestion(
      name: 'Прогулка',
      minimalAction: '10 минут пешком',
      category: 'Здоровье',
      emoji: '🚶',
      why: 'Улучшает настроение и сон',
      habitKind: 'build',
      frequency: 'daily_multi',
      goalType: 'time',
      targetValue: 20,
      unit: 'минут',
      tip: 'Запланируйте прогулку сразу после обеда.',
    ),
    HabitSuggestion(
      name: 'Вода',
      minimalAction: '1 стакан',
      category: 'Здоровье',
      emoji: '💧',
      why: 'Поддерживает энергию в течение дня',
      habitKind: 'build',
      frequency: 'daily',
      goalType: 'quantity',
      targetValue: 6,
      unit: null,
      tip: 'Начинайте день со стакана воды возле кровати.',
    ),
    HabitSuggestion(
      name: 'Растяжка',
      minimalAction: '5 минут',
      category: 'Здоровье',
      emoji: '🧘',
      why: 'Снижает напряжение в спине',
      habitKind: 'build',
      frequency: 'daily',
      goalType: 'time',
      targetValue: 10,
      unit: 'минут',
      tip: 'Сделайте короткий комплекс сразу после пробуждения.',
    ),
    // Вредные привычки
    HabitSuggestion(
      name: 'Курение',
      minimalAction: 'Отложить сигарету на 10 минут',
      category: 'Отказ от зависимостей',
      emoji: '🚭',
      why: 'Формирует паузу перед импульсом',
      habitKind: 'quit',
      frequency: 'daily',
      goalType: null,
      targetValue: null,
      unit: null,
      tip: 'При тяге выпейте воду и сделайте 10 медленных вдохов.',
    ),
    HabitSuggestion(
      name: 'Алкоголь',
      minimalAction: 'Сегодня выбираю безалкогольный вариант',
      category: 'Отказ от зависимостей',
      emoji: '🍷',
      why: 'Уменьшает частоту срывов',
      habitKind: 'quit',
      frequency: 'weekly',
      goalType: null,
      targetValue: null,
      unit: null,
      tip: 'Заранее подготовьте альтернативный напиток на вечер.',
    ),
    HabitSuggestion(
      name: 'Сладкое на ночь',
      minimalAction: 'Заменить десерт на фрукт',
      category: 'Питание',
      emoji: '🍰',
      why: 'Стабилизирует сон и аппетит',
      habitKind: 'quit',
      frequency: 'daily',
      goalType: null,
      targetValue: null,
      unit: null,
      tip: 'Уберите сладкое из видимых мест, держите фрукты под рукой.',
    ),
    HabitSuggestion(
      name: 'Соцсети перед сном',
      minimalAction: 'Без телефона последние 30 минут',
      category: 'Цифровая гигиена',
      emoji: '📵',
      why: 'Улучшает засыпание',
      habitKind: 'quit',
      frequency: 'daily',
      goalType: 'time',
      targetValue: 30,
      unit: 'минут',
      tip: 'Поставьте телефон на зарядку в другой комнате.',
    ),
    HabitSuggestion(
      name: 'Переедание',
      minimalAction: 'Сделать паузу 5 минут перед добавкой',
      category: 'Питание',
      emoji: '🥡',
      why: 'Помогает слышать насыщение',
      habitKind: 'quit',
      frequency: 'daily',
      goalType: null,
      targetValue: null,
      unit: null,
      tip: 'Ешьте медленно и без экрана, чтобы не терять сигнал сытости.',
    ),
    HabitSuggestion(
      name: 'Нецензурная речь',
      minimalAction: 'Заменить грубое слово нейтральным',
      category: 'Коммуникация',
      emoji: '🧠',
      why: 'Снижает эмоциональные конфликты',
      habitKind: 'quit',
      frequency: 'daily',
      goalType: null,
      targetValue: null,
      unit: null,
      tip: 'Составьте список замен и держите его в заметках.',
    ),
  ];

  static List<HabitSuggestion> getByCategory(String category, String kind) {
    return all.where((s) => s.category == category && s.habitKind == kind).toList();
  }

  static List<String> categoriesByKind(String kind) {
    return all.where((s) => s.habitKind == kind).map((s) => s.category).toSet().toList();
  }
}

