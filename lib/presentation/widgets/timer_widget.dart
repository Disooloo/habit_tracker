import 'package:flutter/material.dart';
import 'dart:math' as math;

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
                remainingSeconds.toString(),
                style: theme.textTheme.displayLarge?.copyWith(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'секунд',
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        ],
      ),
    );
  }
}


