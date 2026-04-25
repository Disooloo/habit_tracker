import 'package:flutter/material.dart';

class FeedbackScreen extends StatelessWidget {
  const FeedbackScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Обратная связь')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          Text(
            'Если у вас есть вопрос, ошибка или предложение по улучшению, свяжитесь с нами:',
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 16),
          ListTile(
            leading: Icon(Icons.person_outline),
            title: Text('Автор'),
            subtitle: Text('Андрей Шфнцев'),
          ),
          ListTile(
            leading: Icon(Icons.email_outlined),
            title: Text('Почта'),
            subtitle: SelectableText('shantsev.a.e@yandex.ru'),
          ),
          ListTile(
            leading: Icon(Icons.public),
            title: Text('VK'),
            subtitle: SelectableText('https://vk.com/disooloo'),
          ),
          ListTile(
            leading: Icon(Icons.telegram),
            title: Text('Telegram'),
            subtitle: SelectableText('https://t.me/disooloo'),
          ),
          SizedBox(height: 12),
          Text(
            'При обращении опишите проблему: что вы делали, что ожидали, что произошло.',
          ),
        ],
      ),
    );
  }
}

