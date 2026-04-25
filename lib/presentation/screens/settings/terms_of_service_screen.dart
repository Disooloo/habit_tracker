import 'package:flutter/material.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Условия использования')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          Text(
            'Используя приложение, вы соглашаетесь с данными условиями.',
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 12),
          Text('1. Назначение приложения'),
          Text('Приложение помогает вести и отслеживать привычки.'),
          SizedBox(height: 12),
          Text('2. Ответственность пользователя'),
          Text('Пользователь самостоятельно принимает решения на основе данных приложения.'),
          SizedBox(height: 12),
          Text('3. Подписки'),
          Text('В приложении доступны тарифы. Оплата может быть временно недоступна.'),
          SizedBox(height: 12),
          Text('4. Ограничение ответственности'),
          Text('Приложение предоставляется "как есть", без гарантий бесперебойной работы.'),
          SizedBox(height: 12),
          Text('5. Поддержка'),
          Text('Контакты поддержки: shantsev.a.e@yandex.ru'),
        ],
      ),
    );
  }
}

