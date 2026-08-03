import 'package:flutter/material.dart';
import '../../domain/timer_mode.dart';
import '../../domain/timer_state.dart';
import '../../../../core/constants/app_colors.dart';

class TimerDisplay extends StatelessWidget {
  final TimerState timerState;

  const TimerDisplay({super.key, required this.timerState});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final TimerMode? mode = timerState.activeMode;
    final Color modeColor =
        mode?.color ??
        (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Minimalist mode badge
        AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          opacity: timerState.status == TimerStatus.idle ? 0.6 : 1.0,
          child: Text(
            mode?.title.toUpperCase() ?? 'READY',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 4.0,
              color: modeColor,
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Central Minimalist Numeric Timer
        Text(
          timerState.status == TimerStatus.idle
              ? (mode != null
                    ? '${mode.defaultDurationMinutes.toString().padLeft(2, '0')}:00'
                    : '00:00')
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
        AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          opacity: timerState.status == TimerStatus.running ? 0.0 : 1.0,
          child: SizedBox(
            width: 180, // Constrain width so it wraps nicely inside the ring
            child: Text(
              _getStatusSubtitle(),
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color:
                    (isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary)
                        .withValues(alpha: 0.7),
              ),
            ),
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
        return 'Focus session completed';
    }
  }
}
