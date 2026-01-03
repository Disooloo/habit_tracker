import 'package:flutter/material.dart';
import 'package:habit_tracker/l10n/app_localizations.dart';

class OnboardingPage1 extends StatelessWidget {
  const OnboardingPage1({super.key});

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
            Icons.self_improvement,
            size: 120,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 32),
          Text(
            l10n.onboardingTitle1,
            style: theme.textTheme.displayMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.onboardingSubtitle1,
            style: theme.textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

