import 'package:flutter/material.dart';

class TimerWidget extends StatelessWidget {
  final int remainingSeconds;
  final int totalSeconds;

  const TimerWidget({
    super.key,
    required this.remainingSeconds,
    required this.totalSeconds,
  });

  @override
  Widget build(BuildContext context) {
    final progress = 1.0 - (remainingSeconds / totalSeconds);
    final theme = Theme.of(context);
    final minutes = remainingSeconds ~/ 60;
    final seconds = remainingSeconds % 60;
    final formatted = '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    final isRu = Localizations.localeOf(context).languageCode.startsWith('ru');

    return SizedBox(
      width: 200,
      height: 200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background circle
          SizedBox(
            width: 200,
            height: 200,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 12,
              backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
            ),
          ),
          // Time text
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                formatted,
                style: theme.textTheme.displayLarge?.copyWith(
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                isRu ? 'минуты : секунды' : 'minutes : seconds',
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        ],
      ),
    );
  }
}


