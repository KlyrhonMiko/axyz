import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../domain/timer_mode.dart';
import '../../providers/sensor_gesture_provider.dart';
import '../../providers/timer_provider.dart';
import '../../../../core/constants/app_colors.dart';

class OrientationGuide extends ConsumerWidget {
  const OrientationGuide({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gestureState = ref.watch(sensorGestureProvider);
    final timerState = ref.watch(timerProvider);
    final isLocked = timerState.status.isLocked;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Sensor Status Banner
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : AppColors.lightCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            ),
          ),
          child: Row(
            children: [
              Icon(
                gestureState.isDebouncing
                    ? LucideIcons.loader2
                    : (isLocked ? LucideIcons.lock : LucideIcons.compass),
                size: 18,
                color: gestureState.isDebouncing
                    ? Colors.amber
                    : (isLocked ? AppColors.darkTextMuted : AppColors.accentDeepWork),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isLocked
                          ? 'STATE LOCKED'
                          : (gestureState.isDebouncing ? 'DEBOUNCING GESTURE...' : 'LIVE POSTURE'),
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                        color: AppColors.darkTextMuted,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isLocked
                          ? 'Return to Neutral (Face Up) anytime'
                          : gestureState.currentOrientation.label,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              if (!isLocked) ...[
                Text(
                  'XYZ TELEMETRY',
                  style: TextStyle(
                    fontSize: 9,
                    fontFamily: 'monospace',
                    color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                  ),
                ),
              ],
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Orientation Triggers Grid / List
        const Text(
          'TILT TRIGGERS',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 2.0,
            color: AppColors.darkTextMuted,
          ),
        ),
        const SizedBox(height: 8),

        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: TimerMode.values.map((mode) {
            final isCurrentMode = timerState.activeMode == mode;
            final isOrientationMatch = gestureState.currentOrientation == mode.triggerOrientation;

            return _TriggerChip(
              mode: mode,
              isCurrentMode: isCurrentMode,
              isOrientationMatch: isOrientationMatch,
              isLocked: isLocked,
              onTap: () {
                if (!isLocked) {
                  ref.read(sensorGestureProvider.notifier).simulateOrientation(mode.triggerOrientation);
                }
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _TriggerChip extends StatelessWidget {
  final TimerMode mode;
  final bool isCurrentMode;
  final bool isOrientationMatch;
  final bool isLocked;
  final VoidCallback onTap;

  const _TriggerChip({
    required this.mode,
    required this.isCurrentMode,
    required this.isOrientationMatch,
    required this.isLocked,
    required this.onTap,
  });

  IconData _getIconForMode(TimerMode mode) {
    switch (mode) {
      case TimerMode.deepWork:
        return LucideIcons.smartphoneCharging; // Face down
      case TimerMode.pomodoro:
        return LucideIcons.arrowUp;
      case TimerMode.shortBreak:
        return LucideIcons.arrowDown;
      case TimerMode.longBreak:
        return LucideIcons.arrowLeft;
      case TimerMode.customFocus:
        return LucideIcons.arrowRight;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final Color chipBg = isCurrentMode
        ? mode.color.withValues(alpha: 0.18)
        : (isOrientationMatch
            ? mode.color.withValues(alpha: 0.10)
            : (isDark ? AppColors.darkSurface : AppColors.lightSurface));

    final Color borderColor = isCurrentMode || isOrientationMatch
        ? mode.color.withValues(alpha: 0.5)
        : (isDark ? AppColors.darkBorder : AppColors.lightBorder);

    return InkWell(
      onTap: isLocked ? null : onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: chipBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getIconForMode(mode),
              size: 15,
              color: isCurrentMode || isOrientationMatch
                  ? mode.color
                  : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
            ),
            const SizedBox(width: 8),
            Text(
              mode.title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isCurrentMode ? FontWeight.w600 : FontWeight.w500,
                color: isCurrentMode
                    ? mode.color
                    : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '${mode.defaultDurationMinutes}m',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w400,
                color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
