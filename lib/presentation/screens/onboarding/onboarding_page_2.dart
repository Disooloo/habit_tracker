import 'package:flutter/material.dart';
import 'package:habit_tracker/l10n/app_localizations.dart';

class OnboardingPage2 extends StatelessWidget {
  const OnboardingPage2({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite,
            size: 120,
            color: theme.colorScheme.secondary,
          ),
          const SizedBox(height: 32),
          Text(
            l10n.onboardingTitle2,
            style: theme.textTheme.displayMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.onboardingSubtitle2,
            style: theme.textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          _buildBulletPoint(
            context,
            Icons.check_circle_outline,
            'Минимум усилий',
          ),
          const SizedBox(height: 16),
          _buildBulletPoint(
            context,
            Icons.sentiment_satisfied_alt,
            'Без стыда',
          ),
          const SizedBox(height: 16),
          _buildBulletPoint(
            context,
            Icons.refresh,
            'Можно возвращаться',
          ),
        ],
      ),
    );
  }

  Widget _buildBulletPoint(BuildContext context, IconData icon, String text) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: theme.colorScheme.secondary),
        const SizedBox(width: 12),
        Text(
          text,
          style: theme.textTheme.bodyLarge,
        ),
      ],
    );
  }
}

