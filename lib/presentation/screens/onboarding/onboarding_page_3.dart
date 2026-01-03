import 'package:flutter/material.dart';
import 'package:habit_tracker/l10n/app_localizations.dart';

class OnboardingPage3 extends StatelessWidget {
  final VoidCallback onCreateHabit;

  const OnboardingPage3({
    super.key,
    required this.onCreateHabit,
  });

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
            Icons.play_circle_outline,
            size: 120,
            color: theme.colorScheme.tertiary,
          ),
          const SizedBox(height: 32),
          Text(
            l10n.onboardingTitle3,
            style: theme.textTheme.displayMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.onboardingSubtitle3,
            style: theme.textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          ElevatedButton(
            onPressed: onCreateHabit,
            child: Text(l10n.createHabit),
          ),
        ],
      ),
    );
  }
}

