import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isRu = Localizations.localeOf(context).languageCode.startsWith('ru');
    return Scaffold(
      appBar: AppBar(
        title: Text(isRu ? 'Политика конфиденциальности' : 'Privacy Policy'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            isRu
                ? 'Мы уважаем вашу приватность и храним данные локально на вашем устройстве.'
                : 'We respect your privacy and store data locally on your device.',
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 12),
          Text(isRu ? '1. Какие данные хранятся' : '1. What data is stored'),
          Text(
            isRu
                ? 'Привычки, трекинг, заметки дневника, настройки уведомлений и приложения.'
                : 'Habits, tracking history, diary notes, notification settings, and app settings.',
          ),
          const SizedBox(height: 12),
          Text(isRu ? '2. Где хранятся данные' : '2. Where data is stored'),
          Text(
            isRu
                ? 'Данные сохраняются локально на устройстве пользователя.'
                : 'Data is stored locally on the user device.',
          ),
          const SizedBox(height: 12),
          Text(isRu ? '3. Передача третьим лицам' : '3. Third-party sharing'),
          Text(
            isRu
                ? 'Мы не передаем персональные данные третьим лицам в текущей версии приложения.'
                : 'We do not share personal data with third parties in the current app version.',
          ),
          const SizedBox(height: 12),
          Text(isRu ? '4. Удаление данных' : '4. Data deletion'),
          Text(
            isRu
                ? 'Вы можете удалить все данные через настройки: "Сбросить все привычки и записи".'
                : 'You can remove all data in settings via "Reset all habits and records".',
          ),
          const SizedBox(height: 12),
          Text(isRu ? '5. Контакты' : '5. Contacts'),
          const Text('shantsev.a.e@yandex.ru'),
        ],
      ),
    );
  }
}

