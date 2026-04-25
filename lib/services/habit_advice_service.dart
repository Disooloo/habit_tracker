import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class HabitAdviceService {
  static const String _historyPrefix = 'habit_advice_history_';
  static const int _historySize = 20;

  static const List<String> _generic = [
    'Сделайте первый шаг на 2 минуты и зафиксируйте прогресс.',
    'Подготовьте среду заранее: уберите отвлекающие факторы.',
    'Свяжите привычку с уже существующим ритуалом дня.',
    'Минимальный шаг важнее идеального результата.',
    'Отмечайте даже маленький успех - так легче держать ритм.',
  ];

  static const Map<String, List<String>> _byKeyword = {
    'кур': [
      'При тяге сделайте 10 глубоких вдохов и выпейте воду.',
      'Уберите триггеры: зажигалки и сигареты из быстрого доступа.',
      'Отложите импульс на 10 минут - желание часто проходит.',
    ],
    'алког': [
      'Заранее выберите безалкогольную альтернативу на вечер.',
      'Планируйте встречи без алкоголя в первые недели.',
      'Отслеживайте, в какие моменты тянет выпить, и меняйте сценарий.',
    ],
    'сон': [
      'За 30 минут до сна уберите телефон и яркий свет.',
      'Старайтесь ложиться и вставать в одно и то же время.',
      'Короткая вечерняя рутина помогает быстрее заснуть.',
    ],
    'вода': [
      'Поставьте бутылку воды на видное место.',
      'Выпивайте один стакан сразу после пробуждения.',
      'Привяжите воду к приему пищи и перерывам.',
    ],
    'чтен': [
      'Держите книгу рядом, чтобы начать без подготовки.',
      'Читайте по 5-10 минут в одно и то же время.',
      'Фиксируйте одну мысль после чтения - это закрепляет привычку.',
    ],
  };

  static const List<String> _startPhrases = [
    'Начните с минимального шага',
    'Снизьте порог входа',
    'Сделайте привычку заметной',
    'Привяжите действие к текущему ритуалу',
    'Планируйте заранее',
    'Фиксируйте даже маленький прогресс',
    'Уберите лишние препятствия',
    'Используйте короткие интервалы',
    'Подготовьте окружение',
    'Отмечайте результат сразу после выполнения',
  ];

  static const List<String> _actions = [
    'на 2 минуты',
    'на 5 минут',
    'в первые 15 минут после пробуждения',
    'сразу после обеда',
    'до 11:00',
    'перед сном',
    'после рабочего блока',
    'после прогулки',
    'перед первым кофе',
    'после душа',
  ];

  static const List<String> _boosters = [
    'и похвалите себя за старт',
    'и запишите короткий итог',
    'и отметьте галочку в трекере',
    'и уберите следующий барьер',
    'и подготовьте следующий шаг на завтра',
    'и зафиксируйте, что помогло',
    'и не требуйте идеального результата',
    'и удерживайте ритм хотя бы 3 дня подряд',
    'и повторите в то же время завтра',
    'и завершите на позитивной ноте',
  ];

  List<String> _poolForHabit(String habitName) {
    final lower = habitName.toLowerCase();
    final result = <String>[..._generic];
    for (final entry in _byKeyword.entries) {
      if (lower.contains(entry.key)) {
        result.addAll(entry.value);
      }
    }
    for (final s in _startPhrases) {
      for (final a in _actions) {
        for (final b in _boosters) {
          result.add('$s "$habitName" $a $b.');
        }
      }
    }
    return result;
  }

  Future<String> getAdviceForHabit(int habitId, String habitName) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_historyPrefix$habitId';
    final historyRaw = prefs.getString(key);
    final history = historyRaw == null
        ? <String>[]
        : List<String>.from(jsonDecode(historyRaw) as List<dynamic>);

    final pool = _poolForHabit(habitName);
    String chosen = pool.first;

    for (final candidate in pool) {
      if (!history.contains(candidate)) {
        chosen = candidate;
        break;
      }
    }

    if (history.contains(chosen)) {
      final idx = DateTime.now().millisecond % pool.length;
      chosen = pool[idx];
    }

    final nextHistory = [chosen, ...history.where((e) => e != chosen)]
        .take(_historySize)
        .toList();
    await prefs.setString(key, jsonEncode(nextHistory));
    return chosen;
  }
}

