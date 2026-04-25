import '../domain/entities/habit.dart';

class HabitLocalizationService {
  static final Map<String, String> _ruToEnName = {
    'Глубокая работа': 'Deep Work',
    'Чтение книги': 'Book Reading',
    'Прогулка': 'Walk',
    'Вода': 'Water',
    'Растяжка': 'Stretching',
    'Курение': 'Smoking',
    'Алкоголь': 'Alcohol',
    'Сладкое на ночь': 'Late-night sweets',
    'Соцсети перед сном': 'Social media before sleep',
    'Переедание': 'Overeating',
    'Нецензурная речь': 'Swearing',
  };

  static final Map<String, String> _enToRuName = {
    for (final e in _ruToEnName.entries) e.value: e.key,
  };

  static final Map<String, String> _ruToEnAction = {
    '10 минут без отвлечений': '10 minutes distraction-free',
    '1 страница': '1 page',
    '10 минут пешком': '10 minutes walking',
    '1 стакан': '1 glass',
    '5 минут': '5 minutes',
    'Отложить сигарету на 10 минут': 'Delay a cigarette for 10 minutes',
    'Сегодня выбираю безалкогольный вариант': 'Choose non-alcoholic option today',
    'Заменить десерт на фрукт': 'Replace dessert with fruit',
    'Без телефона последние 30 минут': 'No phone for last 30 minutes',
    'Сделать паузу 5 минут перед добавкой': 'Pause 5 minutes before extra serving',
    'Заменить грубое слово нейтральным': 'Replace rude words with neutral ones',
  };

  static final Map<String, String> _enToRuAction = {
    for (final e in _ruToEnAction.entries) e.value: e.key,
  };

  static String localizeHabitName(String value, String languageCode) {
    if (languageCode.startsWith('ru')) {
      return _enToRuName[value] ?? value;
    }
    return _ruToEnName[value] ?? value;
  }

  static String localizeMinimalAction(String value, String languageCode) {
    if (languageCode.startsWith('ru')) {
      return _enToRuAction[value] ?? value;
    }
    return _ruToEnAction[value] ?? value;
  }

  static Habit localizedHabit(Habit habit, String languageCode) {
    return habit.copyWith(
      name: localizeHabitName(habit.name, languageCode),
      minimalAction: localizeMinimalAction(habit.minimalAction, languageCode),
      unit: _localizeUnit(habit.unit, languageCode),
    );
  }

  static String? _localizeUnit(String? unit, String languageCode) {
    if (unit == null) return null;
    final isRu = languageCode.startsWith('ru');
    if (isRu) {
      switch (unit) {
        case 'minutes':
          return 'минут';
        case 'hours':
          return 'часов';
        case 'seconds':
          return 'секунд';
      }
      return unit;
    }
    switch (unit) {
      case 'минут':
        return 'minutes';
      case 'часов':
        return 'hours';
      case 'секунд':
        return 'seconds';
      default:
        return unit;
    }
  }
}

