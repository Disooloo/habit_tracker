import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class HabitAdviceService {
  static const String _historyPrefix = 'habit_advice_history_';
  static const int _historySize = 20;

  static const List<String> _ruGeneric = [
    'Сфокусируйся на минимальном шаге: лучше стабильно, чем идеально.',
    'Заранее подготовь среду: меньше трения - выше шанс выполнить.',
    'Привяжи привычку к уже существующему ритуалу в течение дня.',
    'Отмечай прогресс сразу после выполнения, чтобы закрепить цикл.',
  ];

  static const List<String> _enGeneric = [
    'Focus on the minimum step: consistent beats perfect.',
    'Prepare your environment in advance to reduce friction.',
    'Attach the habit to an existing daily routine.',
    'Mark progress right after completion to reinforce the loop.',
  ];

  static const Map<String, List<String>> _ruByKeyword = {
    'чтен': [
      'Выдели одно фиксированное время для чтения и убери телефон из поля зрения.',
      'Начинай с 10 минут, чтобы входить в ритм без сопротивления.',
      'После чтения фиксируй одну практическую мысль, чтобы был результат.',
      'Если день сложный, сделай хотя бы 2 страницы - цепочка важнее объема.',
    ],
    'спорт': [
      'Готовь форму заранее с вечера, чтобы утром не тратить волю на старт.',
      'Чередуй нагрузку: тяжелый/легкий день, чтобы не перегореть.',
      'Ставь метрику недели (тренировки/минуты), а не только цель дня.',
      'Отмечай самочувствие после тренировки - это усиливает мотивацию.',
    ],
    'бег': [
      'Перед бегом делай короткую разминку 5-7 минут, чтобы снизить риск травм.',
      'Держи комфортный темп: устойчивость важнее скорости в начале.',
      'Планируй маршрут заранее, чтобы не решать это в последний момент.',
      'Раз в неделю делай восстановительный легкий забег.',
    ],
    'вода': [
      'Поставь напоминание на первые 2-3 часа дня, чтобы быстро набрать темп.',
      'Пей воду небольшими порциями в течение дня, а не большими залпами.',
      'Держи бутылку в прямой видимости на рабочем столе.',
      'Привяжи воду к триггерам: после пробуждения, еды и прогулки.',
    ],
    'сон': [
      'За 60 минут до сна переходи в тихий режим без ярких экранов.',
      'Стабильное время подъема важнее идеального времени отхода ко сну.',
      'Ограничь кофеин во второй половине дня для более глубокого сна.',
      'Сделай короткий вечерний ритуал: душ, дыхание, затемнение комнаты.',
    ],
    'кур': [
      'При тяге отложи решение на 10 минут и сделай 10 спокойных вдохов.',
      'Убери очевидные триггеры: пачки, зажигалки, места автоматического курения.',
      'Замени ритуал перекуров на короткую прогулку или воду.',
      'Считай не срывы, а количество устойчивых отказов от импульса.',
    ],
    'алког': [
      'Продумай заранее безалкогольный вариант для встреч и вечеров.',
      'Убери алкоголь из дома на этапе формирования новой нормы.',
      'Если есть триггер-стресс, заранее выбери замену: душ, прогулка, звонок.',
      'Фиксируй ясные утра как главный бонус отказа.',
    ],
    'слад': [
      'Не держи сладкое на виду: доступность напрямую влияет на срыв.',
      'Добавь белок и клетчатку в основные приемы пищи для стабильного аппетита.',
      'Сладкое лучше планировать заранее, чем есть импульсивно.',
      'Вечернюю тягу снимай чаем, фруктом или ранним сном.',
    ],
    'соцсет': [
      'Убери иконки соцсетей с первого экрана телефона.',
      'Отключи неважные уведомления, чтобы не дергаться на каждый сигнал.',
      'Назначь фиксированные окна для соцсетей вместо режима "всегда онлайн".',
      'Перед открытием соцсети спрашивай себя о цели захода.',
    ],
    'энерг': [
      'Провалы энергии сначала закрывай сном, водой и короткой ходьбой.',
      'Отслеживай, в какие часы чаще тянет к стимуляторам - это зона риска.',
      'Замени энергетик на альтернативу с меньшей нагрузкой на нервную систему.',
      'Питайся регулярно: резкие скачки сахара усиливают тягу к энергетикам.',
    ],
  };

  static const Map<String, List<String>> _enByKeyword = {
    'read': [
      'Use one fixed reading slot and keep your phone away.',
      'Start with 10 minutes to lower resistance.',
      'Capture one practical takeaway after each session.',
      'On hard days, do just 2 pages to keep the streak alive.',
    ],
    'sport': [
      'Prepare workout clothes in advance to make starting easier.',
      'Alternate hard and light days to prevent burnout.',
      'Track weekly volume, not just single-day performance.',
      'Log post-workout mood to reinforce motivation.',
    ],
    'run': [
      'Warm up for 5-7 minutes before running to reduce injury risk.',
      'Keep an easy pace; consistency matters more than speed early on.',
      'Pre-plan route and time to avoid last-minute decisions.',
      'Schedule one recovery run every week.',
    ],
    'water': [
      'Use reminders early in the day to build momentum.',
      'Drink in small portions through the day.',
      'Keep your bottle visible on your desk.',
      'Attach water to triggers: wake-up, meals, and walks.',
    ],
    'sleep': [
      'Switch to low-stimulation mode 60 minutes before bed.',
      'Consistent wake-up time is the backbone of good sleep.',
      'Limit caffeine in the second half of the day.',
      'Create a short evening routine to signal sleep time.',
    ],
    'smok': [
      'Delay the urge by 10 minutes and use slow breathing.',
      'Remove obvious smoking triggers from your environment.',
      'Replace smoke breaks with a short walk or water.',
      'Track resisted urges, not only slips.',
    ],
    'alco': [
      'Pick non-alcohol alternatives before social events.',
      'Keep alcohol out of home during your reset phase.',
      'Plan a stress replacement routine in advance.',
      'Record clear-morning benefits to strengthen commitment.',
    ],
    'sweet': [
      'Keep sweets out of immediate reach and sight.',
      'Add protein and fiber to stabilize appetite.',
      'Plan treats intentionally instead of impulsively.',
      'Handle evening cravings with tea, fruit, or earlier sleep.',
    ],
    'social': [
      'Move social apps off the home screen.',
      'Disable noisy notifications to reduce impulse checks.',
      'Use fixed windows for social media instead of all-day access.',
      'Ask yourself why before opening a social app.',
    ],
    'energy': [
      'Address low energy with sleep, water, and movement first.',
      'Track high-risk hours when cravings peak.',
      'Replace energy drinks with lower-stimulation options.',
      'Keep regular meals to avoid sugar crashes.',
    ],
  };

  Future<String> getAdviceForHabit(int habitId, String habitName) async {
    final isRu = _isRu(habitName);
    final pool = _poolForHabit(habitName, isRu);
    final prefs = await SharedPreferences.getInstance();

    final key = '$_historyPrefix$habitId';
    final historyRaw = prefs.getString(key);
    final history = historyRaw == null
        ? <String>[]
        : List<String>.from(jsonDecode(historyRaw) as List<dynamic>);

    String chosen = pool.first;
    for (final tip in pool) {
      if (!history.contains(tip)) {
        chosen = tip;
        break;
      }
    }

    final nextHistory = [chosen, ...history.where((e) => e != chosen)]
        .take(_historySize)
        .toList();
    await prefs.setString(key, jsonEncode(nextHistory));
    return chosen;
  }

  List<String> _poolForHabit(String habitName, bool isRu) {
    final lower = habitName.toLowerCase();
    final map = isRu ? _ruByKeyword : _enByKeyword;
    final pool = <String>[];
    for (final entry in map.entries) {
      if (lower.contains(entry.key)) {
        pool.addAll(entry.value);
      }
    }
    if (pool.isEmpty) {
      pool.addAll(isRu ? _ruGeneric : _enGeneric);
    }
    return pool;
  }

  bool _isRu(String habitName) {
    return RegExp(r'[А-Яа-яЁё]').hasMatch(habitName);
  }
}
