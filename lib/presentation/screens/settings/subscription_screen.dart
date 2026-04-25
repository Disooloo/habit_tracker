import 'package:flutter/material.dart';
import '../../../services/subscription_service.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  String? _activePlan;
  DateTime? _activeUntil;
  final TextEditingController _promoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSubscriptionState();
  }

  Future<void> _loadSubscriptionState() async {
    final service = SubscriptionService();
    final plan = await service.getActivePlan();
    final until = await service.getActiveUntil();
    if (!mounted) return;
    setState(() {
      _activePlan = plan;
      _activeUntil = until;
    });
  }

  int _discountPercent({
    required int monthPrice,
    required int months,
    required int packagePrice,
  }) {
    final fullPrice = monthPrice * months;
    final saved = fullPrice - packagePrice;
    if (saved <= 0) return 0;
    return ((saved / fullPrice) * 100).round();
  }

  Future<void> _activatePromo() async {
    final result =
        await SubscriptionService().activatePromoCode(_promoController.text);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result.message)),
    );
    if (result.success) {
      _promoController.clear();
      await _loadSubscriptionState();
    }
  }

  Future<void> _onActivatePlan(String planName) async {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Подписка "$planName"'),
        content: const Text(
          'В данный момент оплатить нельзя. Обратитесь в техническую поддержку.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Закрыть'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushNamed('/feedback');
            },
            child: const Text('В обратную связь'),
          ),
        ],
      ),
    );
  }

  Widget _planDurationLine({
    required String title,
    required int price,
    required int monthPrice,
    required int months,
  }) {
    final discount = _discountPercent(
      monthPrice: monthPrice,
      months: months,
      packagePrice: price,
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title),
        Text(
          discount > 0 ? '$price р  (скидка $discount%)' : '$price р',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildPlanCard({
    required String planName,
    required Color color,
    required int monthPrice,
    required int quarterPrice,
    required int yearPrice,
    required List<String> features,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.22), color.withOpacity(0.08)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              planName,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 10),
            _planDurationLine(
              title: '1 месяц',
              price: monthPrice,
              monthPrice: monthPrice,
              months: 1,
            ),
            const SizedBox(height: 6),
            _planDurationLine(
              title: '3 месяца',
              price: quarterPrice,
              monthPrice: monthPrice,
              months: 3,
            ),
            const SizedBox(height: 6),
            _planDurationLine(
              title: '12 месяцев',
              price: yearPrice,
              monthPrice: monthPrice,
              months: 12,
            ),
            const SizedBox(height: 12),
            ...features.map((f) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text('• $f'),
                )),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () => _onActivatePlan(planName),
                child: const Text('Активировать'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Подписка и промокоды')),
      body: ListView(
        children: [
          if (_activePlan != null && _activeUntil != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Text(
                'Активно: $_activePlan до ${_activeUntil!.day.toString().padLeft(2, '0')}.${_activeUntil!.month.toString().padLeft(2, '0')}.${_activeUntil!.year}',
              ),
            ),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Промокод'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _promoController,
                    textCapitalization: TextCapitalization.characters,
                    decoration: const InputDecoration(
                      labelText: 'Введите промокод',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: _activatePromo,
                      child: const Text('Активировать промокод'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          _buildPlanCard(
            planName: 'Базовая',
            color: Colors.blue,
            monthPrice: 50,
            quarterPrice: 140,
            yearPrice: 500,
            features: const [
              'До 10 привычек',
              'Базовая статистика',
              'Напоминания и дневник',
            ],
          ),
          _buildPlanCard(
            planName: 'Расширенная',
            color: Colors.deepPurple,
            monthPrice: 120,
            quarterPrice: 330,
            yearPrice: 1200,
            features: const [
              'До 50 привычек',
              'Продвинутая статистика и советы',
              'Гибкие шаблоны и история',
            ],
          ),
          _buildPlanCard(
            planName: 'Премеум',
            color: Colors.orange,
            monthPrice: 200,
            quarterPrice: 540,
            yearPrice: 2000,
            features: const [
              'Безлимит привычек',
              'Полная аналитика и прогнозы',
              'Приоритетная поддержка',
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _promoController.dispose();
    super.dispose();
  }
}

