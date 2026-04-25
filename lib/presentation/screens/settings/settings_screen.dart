import 'package:flutter/material.dart';
import 'package:habit_tracker/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_constants.dart';
import '../../../services/notification_service.dart';
import '../../../data/repositories/habit_repository_impl.dart';
import '../../../services/in_app_notification_service.dart';
import '../../../services/habit_diary_service.dart';
import '../../../services/habit_goal_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = false;
  String _language = 'ru';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled =
          prefs.getBool(AppConstants.keyNotificationsEnabled) ?? false;
      _language = prefs.getString(AppConstants.keyLanguage) ?? 'ru';
    });
  }

  Future<void> _toggleNotifications(bool value) async {
    setState(() {
      _notificationsEnabled = value;
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.keyNotificationsEnabled, value);

    if (value) {
      final notificationService = NotificationService();
      final granted = await notificationService.requestPermissions();
      if (granted) {
        await notificationService.scheduleInactivityReminder48h();
        await notificationService.scheduleDailyDayStartReminder();
      }
    } else {
      await NotificationService().cancelAllReminders();
    }
  }

  Future<void> _changeLanguage(String language) async {
    setState(() {
      _language = language;
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.keyLanguage, language);
    // Note: Language change would require app restart in real implementation
  }

  Future<void> _confirmResetAll() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Сбросить все данные?'),
        content: const Text(
          'Вы точно хотите сбросить все свои записи, привычки и историю? Это действие нельзя отменить.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Сбросить'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final repository = HabitRepositoryImpl();
    await repository.deleteAllHabits();
    await InAppNotificationService().clearAll();
    await HabitDiaryService().clearAllEntries();
    await HabitGoalService().clearAllGoals();
    await NotificationService().cancelAllReminders();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Все привычки и записи сброшены')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
      ),
      body: ListView(
        children: [
          // Notifications
          SwitchListTile(
            title: Text(l10n.notifications),
            subtitle: const Text('Мягкие напоминания о привычках'),
            value: _notificationsEnabled,
            onChanged: _toggleNotifications,
          ),
          const Divider(),
          // Language
          ListTile(
            title: Text(l10n.language),
            subtitle: Text(_language == 'ru' ? 'Русский' : 'English'),
            trailing: DropdownButton<String>(
              value: _language,
              items: const [
                DropdownMenuItem(value: 'ru', child: Text('Русский')),
                DropdownMenuItem(value: 'en', child: Text('English')),
              ],
              onChanged: (value) {
                if (value != null) {
                  _changeLanguage(value);
                }
              },
            ),
          ),
          const Divider(),
          ListTile(
            title: const Text('Подписка и промокоды'),
            subtitle: const Text('Тарифы, скидки и активация промокода'),
            leading: const Icon(Icons.workspace_premium_outlined),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).pushNamed('/subscription');
            },
          ),
          const Divider(),
          ListTile(
            title: const Text('Сбросить все привычки и записи'),
            subtitle: const Text('Удалить привычки, трекинг, дневник и уведомления'),
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            onTap: _confirmResetAll,
          ),
          const Divider(),
          // Feedback
          ListTile(
            title: Text(l10n.feedback),
            leading: const Icon(Icons.feedback),
            onTap: () {
              Navigator.of(context).pushNamed('/feedback');
            },
          ),
          // Privacy Policy
          ListTile(
            title: Text(l10n.privacyPolicy),
            leading: const Icon(Icons.privacy_tip),
            onTap: () {
              Navigator.of(context).pushNamed('/privacy-policy');
            },
          ),
          // Terms of Service
          ListTile(
            title: Text(l10n.termsOfService),
            leading: const Icon(Icons.description),
            onTap: () {
              Navigator.of(context).pushNamed('/terms-of-service');
            },
          ),
        ],
      ),
    );
  }

}

