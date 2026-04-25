import 'package:flutter/material.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isRu = Localizations.localeOf(context).languageCode.startsWith('ru');
    return Scaffold(
      appBar: AppBar(
        title: Text(isRu ? 'Условия использования' : 'Terms of Service'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            isRu
                ? 'Используя приложение, вы соглашаетесь с данными условиями.'
                : 'By using the app, you agree to these terms.',
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 12),
          Text(isRu ? '1. Назначение приложения' : '1. App purpose'),
          Text(
            isRu
                ? 'Приложение помогает вести и отслеживать привычки.'
                : 'The app helps users build and track habits.',
          ),
          const SizedBox(height: 12),
          Text(isRu ? '2. Ответственность пользователя' : '2. User responsibility'),
          Text(
            isRu
                ? 'Пользователь самостоятельно принимает решения на основе данных приложения.'
                : 'Users make their own decisions based on app data.',
          ),
          const SizedBox(height: 12),
          Text(isRu ? '3. Подписки' : '3. Subscriptions'),
          Text(
            isRu
                ? 'В приложении доступны тарифы. Оплата может быть временно недоступна.'
                : 'The app includes subscription plans. Payments may be temporarily unavailable.',
          ),
          const SizedBox(height: 12),
          Text(isRu ? '4. Ограничение ответственности' : '4. Limitation of liability'),
          Text(
            isRu
                ? 'Приложение предоставляется "как есть", без гарантий бесперебойной работы.'
                : 'The app is provided "as is", without warranty of uninterrupted service.',
          ),
          const SizedBox(height: 12),
          Text(isRu ? '5. Поддержка' : '5. Support'),
          const Text('shantsev.a.e@yandex.ru'),
        ],
      ),
    );
  }
}

