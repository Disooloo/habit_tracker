import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class FeedbackScreen extends StatelessWidget {
  const FeedbackScreen({super.key});

  Future<void> _open(String url) async {
    final uri = Uri.parse(url);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final isRu = Localizations.localeOf(context).languageCode.startsWith('ru');
    return Scaffold(
      appBar: AppBar(title: Text(isRu ? 'Обратная связь' : 'Feedback')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            isRu
                ? 'Если у вас есть вопрос, ошибка или предложение по улучшению, свяжитесь с нами:'
                : 'If you have a question, bug report or improvement idea, contact us:',
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 16),
          ListTile(
            leading: Icon(Icons.person_outline),
            title: Text(isRu ? 'Автор' : 'Author'),
            subtitle: const Text('Андрей Шанцев'),
          ),
          ListTile(
            leading: Icon(Icons.email_outlined),
            title: Text(isRu ? 'Почта' : 'Email'),
            subtitle: const SelectableText('shantsev.a.e@yandex.ru'),
            trailing: IconButton(
              icon: const Icon(Icons.open_in_new),
              onPressed: () => _open('mailto:shantsev.a.e@yandex.ru'),
            ),
          ),
          ListTile(
            leading: Icon(Icons.public),
            title: Text('VK'),
            subtitle: const SelectableText('https://vk.com/disooloo'),
            trailing: ElevatedButton(
              onPressed: () => _open('https://vk.com/disooloo'),
              child: Text(isRu ? 'Открыть' : 'Open'),
            ),
          ),
          ListTile(
            leading: Icon(Icons.telegram),
            title: Text('Telegram'),
            subtitle: const SelectableText('https://t.me/disooloo'),
            trailing: ElevatedButton(
              onPressed: () => _open('https://t.me/disooloo'),
              child: Text(isRu ? 'Открыть' : 'Open'),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            isRu
                ? 'При обращении опишите проблему: что вы делали, что ожидали, что произошло.'
                : 'When contacting support, describe what you did, expected result, and actual result.',
          ),
        ],
      ),
    );
  }
}

