import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../providers/timer_provider.dart';
import 'widgets/aod_overlay.dart';
import 'widgets/cancel_button.dart';
import 'widgets/orientation_guide.dart';
import 'widgets/progress_ring.dart';
import 'widgets/timer_display.dart';
import '../../settings/presentation/settings_screen.dart';
import '../../../core/constants/app_colors.dart';

class TimerScreen extends ConsumerWidget {
  const TimerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timerState = ref.watch(timerProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final activeColor = timerState.activeMode?.color ??
        (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary);

    return Scaffold(
      body: Stack(
        children: [
          // Main Screen Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                children: [
                  // Sleek Top Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: activeColor.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                              border: Border.all(color: activeColor.withValues(alpha: 0.4)),
                            ),
                            child: Center(
                              child: Text(
                                'X',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                  color: activeColor,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'AXYZ',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 3.5,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const SettingsScreen(),
                            ),
                          );
                        },
                        icon: const Icon(LucideIcons.settings2, size: 20),
                        tooltip: 'Settings & Calibration',
                      ),
                    ],
                  ),

                  const Spacer(),

                  // Central Timer & Progress Ring
                  ProgressRing(
                    progress: timerState.progress,
                    accentColor: activeColor,
                    size: 270.0,
                    child: TimerDisplay(timerState: timerState),
                  ),

                  const Spacer(),

                  // Cancel Control Section (Visible when timer is locked/running)
                  const CancelControlSection(),

                  const SizedBox(height: 16),

                  // Orientation Hardware Triggers Visualizer
                  const OrientationGuide(),

                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),

          // AOD Pitch Black Overlay (Layered on top when active)
          const AodOverlay(),
        ],
      ),
    );
  }
}
