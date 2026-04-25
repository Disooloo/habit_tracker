import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class InAppNotificationItem {
  final String id;
  final String message;
  final DateTime createdAt;

  const InAppNotificationItem({
    required this.id,
    required this.message,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'message': message,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory InAppNotificationItem.fromJson(Map<String, dynamic> json) {
    return InAppNotificationItem(
      id: json['id'] as String,
      message: json['message'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

class InAppNotificationService {
  static const String _itemsKey = 'in_app_notifications_v1';
  static const String _lastOpenKey = 'app_last_opened_at';
  static const int _maxItems = 50;

  Future<List<InAppNotificationItem>> getItems() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_itemsKey);
    if (raw == null || raw.isEmpty) return const [];

    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((e) => InAppNotificationItem.fromJson(e as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<void> addMessage(String message) async {
    final prefs = await SharedPreferences.getInstance();
    final current = await getItems();
    final item = InAppNotificationItem(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      message: message,
      createdAt: DateTime.now(),
    );
    final next = [item, ...current].take(_maxItems).toList();
    final encoded = jsonEncode(next.map((e) => e.toJson()).toList());
    await prefs.setString(_itemsKey, encoded);
  }

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_itemsKey);
  }

  Future<void> markAppOpenedAndHandleInactivity() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final previousOpen = prefs.getString(_lastOpenKey);

    if (previousOpen != null) {
      final prev = DateTime.tryParse(previousOpen);
      if (prev != null && now.difference(prev).inHours >= 48) {
        await addMessage(
          'Рады видеть вас снова! Вы не заходили больше 48 часов. Давайте начнем с маленького шага.',
        );
      }
    }

    await prefs.setString(_lastOpenKey, now.toIso8601String());
  }
}

