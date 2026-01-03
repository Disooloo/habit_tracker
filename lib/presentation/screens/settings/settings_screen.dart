import 'package:flutter/material.dart';
import 'package:habit_tracker/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_constants.dart';
import '../../../services/subscription_service.dart';
import '../../../services/notification_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = false;
  String _language = 'ru';
  bool _subscriptionActive = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final subscriptionActive = await SubscriptionService().isSubscriptionActive();
    setState(() {
      _notificationsEnabled =
          prefs.getBool(AppConstants.keyNotificationsEnabled) ?? false;
      _language = prefs.getString(AppConstants.keyLanguage) ?? 'ru';
      _subscriptionActive = subscriptionActive;
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
      await notificationService.requestPermissions();
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

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
          // Subscription
          ListTile(
            title: Text(l10n.subscription),
            subtitle: Text(
              _subscriptionActive
                  ? 'Премиум активна'
                  : 'Бесплатная версия (до 3 привычек)',
            ),
            trailing: _subscriptionActive
                ? const Icon(Icons.check_circle, color: Colors.green)
                : ElevatedButton(
                    onPressed: () async {
                      await SubscriptionService().purchaseSubscription();
                      await _loadSettings();
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Подписка активирована (тест)'),
                          ),
                        );
                      }
                    },
                    child: const Text('Обновить'),
                  ),
          ),
          const Divider(),
          // Feedback
          ListTile(
            title: Text(l10n.feedback),
            leading: const Icon(Icons.feedback),
            onTap: () {
              // TODO: Open feedback form or email
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Обратная связь будет доступна в будущем'),
                ),
              );
            },
          ),
          // Privacy Policy
          ListTile(
            title: Text(l10n.privacyPolicy),
            leading: const Icon(Icons.privacy_tip),
            onTap: () {
              // TODO: Open privacy policy
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Политика конфиденциальности будет доступна в будущем'),
                ),
              );
            },
          ),
          // Terms of Service
          ListTile(
            title: Text(l10n.termsOfService),
            leading: const Icon(Icons.description),
            onTap: () {
              // TODO: Open terms of service
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Условия использования будут доступны в будущем'),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

