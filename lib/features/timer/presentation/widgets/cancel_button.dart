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


        // On-Screen Cancel Button & Gestures Row
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Minimalist Cancel Button
            IconButton(
              onPressed: () {
                ref.read(timerProvider.notifier).cancelTimer(reason: 'ui');
              },
              icon: const Icon(LucideIcons.x, size: 28),
              color: AppColors.cancelRed.withValues(alpha: 0.7),
              tooltip: 'Cancel Session',
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Hint text for physical cancel gestures
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Or Double Tap Back',
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
