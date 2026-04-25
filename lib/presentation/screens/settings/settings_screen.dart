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
  final String currentLanguage;
  final ThemeMode currentThemeMode;
  final Future<void> Function(String languageCode) onLanguageChanged;
  final Future<void> Function(ThemeMode mode) onThemeModeChanged;

  const SettingsScreen({
    super.key,
    required this.currentLanguage,
    required this.currentThemeMode,
    required this.onLanguageChanged,
    required this.onThemeModeChanged,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = false;
  String _language = 'ru';
  ThemeMode _themeMode = ThemeMode.system;

  @override
  void initState() {
    super.initState();
    _language = widget.currentLanguage;
    _themeMode = widget.currentThemeMode;
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
    await widget.onLanguageChanged(language);
  }

  Future<void> _changeThemeMode(ThemeMode mode) async {
    setState(() {
      _themeMode = mode;
    });
    await widget.onThemeModeChanged(mode);
  }

  Future<void> _confirmResetAll() async {
    final isRu = Localizations.localeOf(context).languageCode.startsWith('ru');
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isRu ? 'Сбросить все данные?' : 'Reset all data?'),
        content: Text(
          isRu
              ? 'Вы точно хотите сбросить все свои записи, привычки и историю? Это действие нельзя отменить.'
              : 'Do you really want to reset all your records, habits and history? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(isRu ? 'Отмена' : 'Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(isRu ? 'Сбросить' : 'Reset'),
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
      SnackBar(
        content: Text(
          isRu ? 'Все привычки и записи сброшены' : 'All habits and records have been reset',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isRu = Localizations.localeOf(context).languageCode.startsWith('ru');

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
      ),
      body: ListView(
        children: [
          // Notifications
          SwitchListTile(
            title: Text(l10n.notifications),
            subtitle: Text(
              isRu ? 'Мягкие напоминания о привычках' : 'Gentle habit reminders',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
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
            title: Text(isRu ? 'Тема' : 'Theme'),
            subtitle: Text(
              _themeMode == ThemeMode.system
                  ? (isRu ? 'Как в устройстве' : 'Follow device')
                  : _themeMode == ThemeMode.light
                      ? (isRu ? 'Светлая' : 'Light')
                      : (isRu ? 'Темная' : 'Dark'),
            ),
            trailing: DropdownButton<ThemeMode>(
              value: _themeMode,
              items: [
                DropdownMenuItem(
                  value: ThemeMode.system,
                  child: Text(isRu ? 'Система' : 'System'),
                ),
                DropdownMenuItem(
                  value: ThemeMode.light,
                  child: Text(isRu ? 'Светлая' : 'Light'),
                ),
                DropdownMenuItem(
                  value: ThemeMode.dark,
                  child: Text(isRu ? 'Темная' : 'Dark'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  _changeThemeMode(value);
                }
              },
            ),
          ),
          const Divider(),
          ListTile(
            title: Text(isRu ? 'Подписка и промокоды' : 'Subscription and promo codes'),
            subtitle: Text(
              isRu ? 'Тарифы, скидки и активация промокода' : 'Plans, discounts and promo activation',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            leading: const Icon(Icons.workspace_premium_outlined),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).pushNamed('/subscription');
            },
          ),
          const Divider(),
          ListTile(
            title: Text(isRu ? 'Сбросить все привычки и записи' : 'Reset all habits and records'),
            subtitle: Text(
              isRu
                  ? 'Удалить привычки, трекинг, дневник и уведомления'
                  : 'Delete habits, tracking, diary and notifications',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
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

