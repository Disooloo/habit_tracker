import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../core/constants/app_constants.dart';
import 'dart:math';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  // Soft reminder messages
  static const List<String> _reminderMessages = [
    'Можно сделать совсем чуть-чуть',
    '30 секунд — уже достаточно',
    'Маленький шаг — это тоже прогресс',
    'Не обязательно делать идеально',
    'Можно начать с малого',
  ];

  Future<void> initialize() async {
    if (_initialized) return;

    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Europe/Moscow')); // Default timezone

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create notification channel for Android
    final androidChannel = AndroidNotificationChannel(
      AppConstants.notificationChannelId.toString(),
      AppConstants.notificationChannelName,
      description: AppConstants.notificationChannelDescription,
      importance: Importance.low, // Soft, not intrusive
    );

    await _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);

    _initialized = true;
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap if needed
  }

  Future<void> scheduleHabitReminder({
    required int habitId,
    required String habitName,
    required String? timeString, // HH:mm format
  }) async {
    if (timeString == null || timeString.isEmpty) return;

    await initialize();

    final parts = timeString.split(':');
    if (parts.length != 2) return;

    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return;

    // Get random soft message
    final random = Random();
    final message = _reminderMessages[random.nextInt(_reminderMessages.length)];

    // Schedule daily notification
    await _notifications.zonedSchedule(
      habitId, // Use habit ID as notification ID
      habitName,
      message,
      _nextInstanceOfTime(hour, minute),
      NotificationDetails(
        android: AndroidNotificationDetails(
          AppConstants.notificationChannelId.toString(),
          AppConstants.notificationChannelName,
          channelDescription: AppConstants.notificationChannelDescription,
          importance: Importance.low,
          priority: Priority.low,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }

  Future<void> cancelHabitReminder(int habitId) async {
    await _notifications.cancel(habitId);
  }

  Future<void> cancelAllReminders() async {
    await _notifications.cancelAll();
  }

  Future<bool> requestPermissions() async {
    final android = _notifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      final granted = await android.requestNotificationsPermission();
      return granted ?? false;
    }

    final ios = _notifications.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
    if (ios != null) {
      final granted = await ios.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }

    return false;
  }
}

