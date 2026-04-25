import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Политика конфиденциальности')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          Text(
            'Мы уважаем вашу приватность и храним данные локально на вашем устройстве.',
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 12),
          Text('1. Какие данные хранятся'),
          Text('Привычки, трекинг, заметки дневника, настройки уведомлений и приложения.'),
          SizedBox(height: 12),
          Text('2. Где хранятся данные'),
          Text('Данные сохраняются локально на устройстве пользователя.'),
          SizedBox(height: 12),
          Text('3. Передача третьим лицам'),
          Text('Мы не передаем персональные данные третьим лицам в текущей версии приложения.'),
          SizedBox(height: 12),
          Text('4. Удаление данных'),
          Text('Вы можете удалить все данные через раздел настроек: "Сбросить все привычки и записи".'),
          SizedBox(height: 12),
          Text('5. Контакты'),
          Text('По вопросам приватности: shantsev.a.e@yandex.ru'),
        ],
      ),
    );
  }
}

