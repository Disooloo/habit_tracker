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
  
  String _formatPrice(int rubPrice, bool isRu) {
    if (isRu) return '$rubPrice ₽';
    final usd = (rubPrice / 100).toStringAsFixed(2);
    return '\$$usd';
  }

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
    final isRu = Localizations.localeOf(context).languageCode.startsWith('ru');
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isRu ? 'Подписка "$planName"' : 'Subscription "$planName"'),
        content: Text(
          isRu
              ? 'В данный момент оплатить нельзя. Обратитесь в техническую поддержку.'
              : 'Payments are currently unavailable. Please contact technical support.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(isRu ? 'Закрыть' : 'Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushNamed('/feedback');
            },
            child: Text(isRu ? 'В обратную связь' : 'Open feedback'),
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
    final isRu = Localizations.localeOf(context).languageCode.startsWith('ru');
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: Text(title, overflow: TextOverflow.ellipsis)),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            discount > 0
                ? (isRu
                    ? '${_formatPrice(price, isRu)} (скидка $discount%)'
                    : '${_formatPrice(price, isRu)} ($discount% off)')
                : _formatPrice(price, isRu),
            style: const TextStyle(fontWeight: FontWeight.w600),
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
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
    final isRu = Localizations.localeOf(context).languageCode.startsWith('ru');
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
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 10),
            _planDurationLine(
              title: isRu ? '1 месяц' : '1 month',
              price: monthPrice,
              monthPrice: monthPrice,
              months: 1,
            ),
            const SizedBox(height: 6),
            _planDurationLine(
              title: isRu ? '3 месяца' : '3 months',
              price: quarterPrice,
              monthPrice: monthPrice,
              months: 3,
            ),
            const SizedBox(height: 6),
            _planDurationLine(
              title: isRu ? '12 месяцев' : '12 months',
              price: yearPrice,
              monthPrice: monthPrice,
              months: 12,
            ),
            const SizedBox(height: 12),
            ...features.map((f) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    '• $f',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                )),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () => _onActivatePlan(planName),
                child: Text(isRu ? 'Активировать' : 'Activate'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isRu = Localizations.localeOf(context).languageCode.startsWith('ru');
    return Scaffold(
      appBar: AppBar(
        title: Text(isRu ? 'Подписка и промокоды' : 'Subscription & Promo Codes'),
      ),
      body: ListView(
        children: [
          Container(
            margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              isRu
                  ? 'Оплата подписок пока не подключена. Спасибо за понимание.'
                  : 'Subscription payments are not connected yet. Thank you for understanding.',
            ),
          ),
          if (_activePlan != null && _activeUntil != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Text(
                isRu
                    ? 'Активно: $_activePlan до ${_activeUntil!.day.toString().padLeft(2, '0')}.${_activeUntil!.month.toString().padLeft(2, '0')}.${_activeUntil!.year}'
                    : 'Active: $_activePlan until ${_activeUntil!.day.toString().padLeft(2, '0')}.${_activeUntil!.month.toString().padLeft(2, '0')}.${_activeUntil!.year}',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(isRu ? 'Промокод' : 'Promo code'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _promoController,
                    textCapitalization: TextCapitalization.characters,
                    decoration: InputDecoration(
                      labelText: isRu ? 'ПРОМОКОД' : 'PROMO CODE',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: _activatePromo,
                      child: Text(isRu ? 'Активировать промокод' : 'Activate promo code'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          _buildPlanCard(
            planName: isRu ? 'Базовая' : 'Basic',
            color: Colors.blue,
            monthPrice: 50,
            quarterPrice: 140,
            yearPrice: 500,
            features: [
              isRu ? 'До 10 привычек' : 'Up to 10 habits',
              isRu ? 'Базовая статистика' : 'Basic analytics',
              isRu
                  ? 'Счётчик привычек (доступно с этого тарифа)'
                  : 'Habit counter (included from this plan)',
              isRu ? 'Напоминания и дневник' : 'Reminders and diary',
            ],
          ),
          _buildPlanCard(
            planName: isRu ? 'Расширенная' : 'Extended',
            color: Colors.deepPurple,
            monthPrice: 120,
            quarterPrice: 330,
            yearPrice: 1200,
            features: [
              isRu ? 'До 50 привычек' : 'Up to 50 habits',
              isRu ? 'Продвинутая статистика и советы' : 'Advanced stats and advice',
              isRu ? 'Гибкие шаблоны и история' : 'Flexible templates and history',
            ],
          ),
          _buildPlanCard(
            planName: isRu ? 'Премеум' : 'Premium',
            color: Colors.orange,
            monthPrice: 200,
            quarterPrice: 540,
            yearPrice: 2000,
            features: [
              isRu ? 'Безлимит привычек' : 'Unlimited habits',
              isRu ? 'Полная аналитика и прогнозы' : 'Full analytics and forecasts',
              isRu ? 'Приоритетная поддержка' : 'Priority support',
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

