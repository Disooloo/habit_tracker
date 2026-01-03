class HabitSuggestion {
  final String name;
  final String minimalAction;
  final String category;
  final String emoji;
  final String why;

  const HabitSuggestion({
    required this.name,
    required this.minimalAction,
    required this.category,
    required this.emoji,
    required this.why,
  });
}

class HabitSuggestions {
  static const List<HabitSuggestion> all = [
    // 🧠 Фокус / работа
    HabitSuggestion(
      name: 'Начать работу',
      minimalAction: 'Открыть нужный файл',
      category: 'Фокус / работа',
      emoji: '🧠',
      why: 'Снимает барьер старта',
    ),
    HabitSuggestion(
      name: 'Фокус',
      minimalAction: '30 секунд без переключений',
      category: 'Фокус / работа',
      emoji: '🧠',
      why: 'Запуск концентрации',
    ),
    HabitSuggestion(
      name: 'Кодинг',
      minimalAction: 'Прочитать 5 строк кода',
      category: 'Фокус / работа',
      emoji: '🧠',
      why: 'Часто приводит к продолжению',
    ),
    HabitSuggestion(
      name: 'Учёба',
      minimalAction: 'Открыть конспект',
      category: 'Фокус / работа',
      emoji: '🧠',
      why: '«Войти» в контекст',
    ),
    // 💪 Здоровье
    HabitSuggestion(
      name: 'Движение',
      minimalAction: '1 присед',
      category: 'Здоровье',
      emoji: '💪',
      why: 'Активирует тело',
    ),
    HabitSuggestion(
      name: 'Спина',
      minimalAction: '30 сек растяжки',
      category: 'Здоровье',
      emoji: '💪',
      why: 'Снимает напряжение',
    ),
    HabitSuggestion(
      name: 'Вода',
      minimalAction: '1 глоток',
      category: 'Здоровье',
      emoji: '💪',
      why: 'Лёгкий якорь',
    ),
    HabitSuggestion(
      name: 'Сон',
      minimalAction: 'Встать с кровати',
      category: 'Здоровье',
      emoji: '💪',
      why: 'Часто сложнее всего',
    ),
    // 📖 Саморазвитие
    HabitSuggestion(
      name: 'Чтение',
      minimalAction: '1 абзац',
      category: 'Саморазвитие',
      emoji: '📖',
      why: 'Часто превращается в 10 минут',
    ),
    HabitSuggestion(
      name: 'Язык',
      minimalAction: '1 слово',
      category: 'Саморазвитие',
      emoji: '📖',
      why: 'Убирает страх «учить»',
    ),
    HabitSuggestion(
      name: 'Письмо',
      minimalAction: '1 предложение',
      category: 'Саморазвитие',
      emoji: '📖',
      why: 'Запускает поток',
    ),
    HabitSuggestion(
      name: 'Медитация',
      minimalAction: '3 дыхания',
      category: 'Саморазвитие',
      emoji: '📖',
      why: 'Не пугает',
    ),
    // 🏠 Быт
    HabitSuggestion(
      name: 'Уборка',
      minimalAction: '1 предмет на место',
      category: 'Быт',
      emoji: '🏠',
      why: 'Против хаоса',
    ),
    HabitSuggestion(
      name: 'Почта',
      minimalAction: 'Открыть 1 письмо',
      category: 'Быт',
      emoji: '🏠',
      why: 'Разгружает тревогу',
    ),
    HabitSuggestion(
      name: 'Финансы',
      minimalAction: 'Открыть банковское приложение',
      category: 'Быт',
      emoji: '🏠',
      why: 'Первый шаг',
    ),
  ];

  static List<HabitSuggestion> getByCategory(String category) {
    return all.where((s) => s.category == category).toList();
  }

  static List<String> get categories {
    return all.map((s) => s.category).toSet().toList();
  }
}

