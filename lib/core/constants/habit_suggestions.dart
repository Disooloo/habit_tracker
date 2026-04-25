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
  static List<HabitSuggestion> all(String languageCode) {
    final isRu = languageCode.toLowerCase().startsWith('ru');
    return [
      HabitSuggestion(
        name: isRu ? 'Глубокая работа' : 'Deep Work',
        minimalAction: isRu ? '10 минут без отвлечений' : '10 minutes distraction-free',
        category: isRu ? 'Продуктивность' : 'Productivity',
        emoji: '🧠',
        why: isRu ? 'Снимает барьер старта' : 'Removes start friction',
        habitKind: 'build',
        frequency: 'daily_multi',
        goalType: 'time',
        targetValue: 25,
        unit: isRu ? 'минут' : 'minutes',
        tip: isRu
            ? 'Отключите уведомления на 25 минут и начните с одной задачи.'
            : 'Disable notifications for 25 minutes and start with one task.',
      ),
      HabitSuggestion(
        name: isRu ? 'Чтение книги' : 'Book Reading',
        minimalAction: isRu ? '1 страница' : '1 page',
        category: isRu ? 'Саморазвитие' : 'Self Development',
        emoji: '📚',
        why: isRu ? 'Постепенно растет концентрация' : 'Concentration grows gradually',
        habitKind: 'build',
        frequency: 'daily_multi',
        goalType: 'quantity',
        targetValue: 10,
        unit: null,
        tip: isRu ? 'Держите книгу рядом с местом отдыха.' : 'Keep a book near your rest area.',
      ),
      HabitSuggestion(
        name: isRu ? 'Прогулка' : 'Walk',
        minimalAction: isRu ? '10 минут пешком' : '10 minutes walking',
        category: isRu ? 'Здоровье' : 'Health',
        emoji: '🚶',
        why: isRu ? 'Улучшает настроение и сон' : 'Improves mood and sleep',
        habitKind: 'build',
        frequency: 'daily_multi',
        goalType: 'time',
        targetValue: 20,
        unit: isRu ? 'минут' : 'minutes',
        tip: isRu
            ? 'Запланируйте прогулку сразу после обеда.'
            : 'Plan your walk right after lunch.',
      ),
      HabitSuggestion(
        name: isRu ? 'Вода' : 'Water',
        minimalAction: isRu ? '1 стакан' : '1 glass',
        category: isRu ? 'Здоровье' : 'Health',
        emoji: '💧',
        why: isRu ? 'Поддерживает энергию в течение дня' : 'Supports energy during the day',
        habitKind: 'build',
        frequency: 'daily_once',
        goalType: 'quantity',
        targetValue: 6,
        unit: null,
        tip: isRu
            ? 'Начинайте день со стакана воды возле кровати.'
            : 'Start your day with a glass of water by your bed.',
      ),
      HabitSuggestion(
        name: isRu ? 'Растяжка' : 'Stretching',
        minimalAction: isRu ? '5 минут' : '5 minutes',
        category: isRu ? 'Здоровье' : 'Health',
        emoji: '🧘',
        why: isRu ? 'Снижает напряжение в спине' : 'Reduces back tension',
        habitKind: 'build',
        frequency: 'daily_once',
        goalType: 'time',
        targetValue: 10,
        unit: isRu ? 'минут' : 'minutes',
        tip: isRu
            ? 'Сделайте короткий комплекс сразу после пробуждения.'
            : 'Do a short routine right after waking up.',
      ),
      HabitSuggestion(
        name: isRu ? 'Ранний подъём' : 'Wake up early',
        minimalAction: isRu ? 'Подъем в 06:30' : 'Wake up at 06:30',
        category: isRu ? 'Продуктивность' : 'Productivity',
        emoji: '⏰',
        why: isRu ? 'Стабилизирует режим дня' : 'Stabilizes daily schedule',
        habitKind: 'build',
        frequency: 'daily_once',
        goalType: 'time',
        targetValue: 1,
        unit: isRu ? 'часов' : 'hours',
        tip: isRu
            ? 'Ложитесь на 20-30 минут раньше и не откладывайте будильник.'
            : 'Go to bed 20-30 minutes earlier and avoid snooze.',
      ),
      HabitSuggestion(
        name: isRu ? 'Здоровый сон 8 часов' : 'Healthy sleep 8 hours',
        minimalAction: isRu ? 'Лечь до 23:00' : 'Go to bed before 23:00',
        category: isRu ? 'Здоровье' : 'Health',
        emoji: '😴',
        why: isRu ? 'Улучшает восстановление и энергию' : 'Improves recovery and energy',
        habitKind: 'build',
        frequency: 'daily_once',
        goalType: 'time',
        targetValue: 8,
        unit: isRu ? 'часов' : 'hours',
        tip: isRu
            ? 'За час до сна уменьшите яркость экрана и избегайте кофеина.'
            : 'Reduce screen brightness and avoid caffeine one hour before sleep.',
      ),
      HabitSuggestion(
        name: isRu ? 'Курение' : 'Smoking',
        minimalAction: isRu ? 'Отложить сигарету на 10 минут' : 'Delay a cigarette for 10 minutes',
        category: isRu ? 'Отказ от зависимостей' : 'Quit Addictions',
        emoji: '🚭',
        why: isRu ? 'Формирует паузу перед импульсом' : 'Creates a pause before impulse',
        habitKind: 'quit',
        frequency: 'daily_once',
        goalType: null,
        targetValue: null,
        unit: null,
        tip: isRu
            ? 'При тяге выпейте воду и сделайте 10 медленных вдохов.'
            : 'When craving hits, drink water and take 10 slow breaths.',
      ),
      HabitSuggestion(
        name: isRu ? 'Алкоголь' : 'Alcohol',
        minimalAction: isRu
            ? 'Сегодня выбираю безалкогольный вариант'
            : 'Choose non-alcoholic option today',
        category: isRu ? 'Отказ от зависимостей' : 'Quit Addictions',
        emoji: '🍷',
        why: isRu ? 'Уменьшает частоту срывов' : 'Reduces relapse frequency',
        habitKind: 'quit',
        frequency: 'weekly',
        goalType: null,
        targetValue: null,
        unit: null,
        tip: isRu
            ? 'Заранее подготовьте альтернативный напиток на вечер.'
            : 'Prepare an alternative drink for the evening in advance.',
      ),
      HabitSuggestion(
        name: isRu ? 'Энергетики' : 'Energy drinks',
        minimalAction: isRu
            ? 'Сегодня без энергетиков'
            : 'No energy drinks today',
        category: isRu ? 'Отказ от зависимостей' : 'Quit Addictions',
        emoji: '⚡',
        why: isRu ? 'Снижает тревожность и скачки сна' : 'Reduces anxiety and sleep crashes',
        habitKind: 'quit',
        frequency: 'daily_once',
        goalType: null,
        targetValue: null,
        unit: null,
        tip: isRu
            ? 'Замените энергетик водой и короткой прогулкой.'
            : 'Replace energy drink with water and a short walk.',
      ),
      HabitSuggestion(
        name: isRu ? 'Сладкое на ночь' : 'Late-night sweets',
        minimalAction: isRu ? 'Заменить десерт на фрукт' : 'Replace dessert with fruit',
        category: isRu ? 'Питание' : 'Nutrition',
        emoji: '🍰',
        why: isRu ? 'Стабилизирует сон и аппетит' : 'Stabilizes sleep and appetite',
        habitKind: 'quit',
        frequency: 'daily_once',
        goalType: null,
        targetValue: null,
        unit: null,
        tip: isRu
            ? 'Уберите сладкое из видимых мест, держите фрукты под рукой.'
            : 'Keep sweets out of sight and fruits within reach.',
      ),
      HabitSuggestion(
        name: isRu ? 'Соцсети перед сном' : 'Social media before sleep',
        minimalAction: isRu ? 'Без телефона последние 30 минут' : 'No phone for last 30 minutes',
        category: isRu ? 'Цифровая гигиена' : 'Digital Hygiene',
        emoji: '📵',
        why: isRu ? 'Улучшает засыпание' : 'Improves falling asleep',
        habitKind: 'quit',
        frequency: 'daily_once',
        goalType: 'time',
        targetValue: 30,
        unit: isRu ? 'минут' : 'minutes',
        tip: isRu
            ? 'Поставьте телефон на зарядку в другой комнате.'
            : 'Charge your phone in another room.',
      ),
      HabitSuggestion(
        name: isRu ? 'Переедание' : 'Overeating',
        minimalAction: isRu ? 'Сделать паузу 5 минут перед добавкой' : 'Pause 5 minutes before extra serving',
        category: isRu ? 'Питание' : 'Nutrition',
        emoji: '🥡',
        why: isRu ? 'Помогает слышать насыщение' : 'Helps notice satiety',
        habitKind: 'quit',
        frequency: 'daily_once',
        goalType: null,
        targetValue: null,
        unit: null,
        tip: isRu
            ? 'Ешьте медленно и без экрана, чтобы не терять сигнал сытости.'
            : 'Eat slowly without a screen to keep satiety signals.',
      ),
      HabitSuggestion(
        name: isRu ? 'Нецензурная речь' : 'Swearing',
        minimalAction: isRu ? 'Заменить грубое слово нейтральным' : 'Replace rude words with neutral ones',
        category: isRu ? 'Коммуникация' : 'Communication',
        emoji: '🗣️',
        why: isRu ? 'Снижает эмоциональные конфликты' : 'Reduces emotional conflicts',
        habitKind: 'quit',
        frequency: 'daily_once',
        goalType: null,
        targetValue: null,
        unit: null,
        tip: isRu
            ? 'Составьте список замен и держите его в заметках.'
            : 'Make a list of replacements and keep it in notes.',
      ),
    ];
  }

  static List<HabitSuggestion> getByCategory(
    String category,
    String kind,
    String languageCode,
  ) {
    return all(languageCode)
        .where((s) => s.category == category && s.habitKind == kind)
        .toList();
  }

  static List<String> categoriesByKind(String kind, String languageCode) {
    return all(languageCode)
        .where((s) => s.habitKind == kind)
        .map((s) => s.category)
        .toSet()
        .toList();
  }
}

