import 'package:flutter/material.dart';
import '../../domain/timer_mode.dart';
import '../../domain/timer_state.dart';
import '../../../../core/constants/app_colors.dart';

class TimerDisplay extends StatelessWidget {
  final TimerState timerState;

  const TimerDisplay({
    super.key,
    required this.timerState,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final TimerMode? mode = timerState.activeMode;
    final Color modeColor = mode?.color ?? (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Mode badge/label
        AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          opacity: timerState.status == TimerStatus.idle ? 0.6 : 1.0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: modeColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: modeColor.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Text(
              mode?.title.toUpperCase() ?? 'READY',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 2.5,
                color: modeColor,
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Central Minimalist Numeric Timer
        Text(
          timerState.status == TimerStatus.idle
              ? '--:--'
              : timerState.formattedTime,
          style: theme.textTheme.displayLarge?.copyWith(
            fontSize: 76,
            fontWeight: FontWeight.w200,
            letterSpacing: -3.0,
            height: 1.0,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        const SizedBox(height: 16),

        // Subtitle status
        Text(
          _getStatusSubtitle(),
          style: theme.textTheme.bodyLarge?.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          ),
        ),
      ],
    );
  }

  String _getStatusSubtitle() {
    switch (timerState.status) {
      case TimerStatus.idle:
        return 'Tilt device to start focus session';
      case TimerStatus.running:
        return 'State locked • Focus active';
      case TimerStatus.paused:
        return 'Session paused';
      case TimerStatus.completed:
        return 'Focus session completed 🎉';
    }
  }
}
