import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../providers/sensor_gesture_provider.dart';
import '../../providers/timer_provider.dart';
import '../../../../core/constants/app_colors.dart';

class CancelControlSection extends ConsumerWidget {
  const CancelControlSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timerState = ref.watch(timerProvider);
    final gestureState = ref.watch(sensorGestureProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (!timerState.status.isLocked) {
      return const SizedBox.shrink();
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Smother progress bar indicator if proximity is being triggered
        if (gestureState.smotherProgress > 0.0) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.cancelRed.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.cancelRed.withValues(alpha: 0.3)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(LucideIcons.hand, size: 14, color: AppColors.cancelRed),
                    SizedBox(width: 8),
                    Text(
                      'SMOTHER CANCELLING...',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                        color: AppColors.cancelRed,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: gestureState.smotherProgress,
                    backgroundColor: AppColors.cancelRed.withValues(alpha: 0.2),
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.cancelRed),
                    minHeight: 4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

        // On-Screen Cancel Button & Gestures Row
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Minimalist Cancel Button
            OutlinedButton.icon(
              onPressed: () {
                ref.read(timerProvider.notifier).cancelTimer(reason: 'ui');
              },
              icon: const Icon(LucideIcons.x, size: 16, color: AppColors.cancelRed),
              label: const Text(
                'CANCEL SESSION',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.5,
                  color: AppColors.cancelRed,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppColors.cancelRed.withValues(alpha: 0.4)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Hint text for physical cancel gestures
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Or Double Tap Back  •  Smother Top (2s)',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w400,
                color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
