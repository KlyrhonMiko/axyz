import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../providers/timer_provider.dart';
import '../providers/sensor_gesture_provider.dart';
import '../domain/timer_mode.dart';
import '../domain/device_orientation_mode.dart';
import '../domain/timer_state.dart';
import '../../settings/providers/settings_provider.dart';
import 'widgets/aod_overlay.dart';
import 'widgets/cancel_button.dart';
import 'widgets/progress_ring.dart';
import 'widgets/timer_display.dart';
import 'widgets/spatial_indicators.dart';
import 'widgets/sector_ring_indicator.dart';
import '../../settings/presentation/settings_screen.dart';
import '../../../core/constants/app_colors.dart';

class TimerScreen extends ConsumerWidget {
  const TimerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timerState = ref.watch(timerProvider);
    final sensorState = ref.watch(sensorGestureProvider);
    final settings = ref.watch(settingsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final activeColor = timerState.activeMode?.color ??
        (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary);

    final pendingMode = TimerMode.fromOrientation(sensorState.pendingOrientation);
    final upcomingColor = pendingMode?.color ?? activeColor;

    double getAngleForOrientation(DeviceOrientationMode? mode) {
      switch (mode) {
        case DeviceOrientationMode.portraitUp:
          return -pi / 2;
        case DeviceOrientationMode.portraitDown:
          return pi / 2;
        case DeviceOrientationMode.landscapeLeft:
          return pi;
        case DeviceOrientationMode.landscapeRight:
          return 0.0;
        default:
          return 0.0;
      }
    }

    return Scaffold(
      body: Listener(
        onPointerDown: (_) => ref.read(timerProvider.notifier).registerInteraction(),
        onPointerMove: (_) => ref.read(timerProvider.notifier).registerInteraction(),
        behavior: HitTestBehavior.translucent,
        child: Stack(
          children: [
            // Background Indicators (Edge Dots & Center Glow)
            if (timerState.status == TimerStatus.idle) ...[
              EdgeDotIndicator(
                alignment: Alignment.topCenter,
                color: TimerMode.pomodoro.color,
                isActive: sensorState.pendingOrientation == DeviceOrientationMode.portraitUp && sensorState.isDebouncing,
              ),
              EdgeDotIndicator(
                alignment: Alignment.bottomCenter,
                color: TimerMode.shortBreak.color,
                isActive: sensorState.pendingOrientation == DeviceOrientationMode.portraitDown && sensorState.isDebouncing,
              ),
              EdgeDotIndicator(
                alignment: Alignment.centerLeft,
                color: TimerMode.longBreak.color,
                isActive: sensorState.pendingOrientation == DeviceOrientationMode.landscapeLeft && sensorState.isDebouncing,
              ),
              EdgeDotIndicator(
                alignment: Alignment.centerRight,
                color: TimerMode.customFocus.color,
                isActive: sensorState.pendingOrientation == DeviceOrientationMode.landscapeRight && sensorState.isDebouncing,
              ),
              CenterGlowIndicator(
                isActive: sensorState.pendingOrientation == DeviceOrientationMode.faceDown && sensorState.isDebouncing,
                color: TimerMode.deepWork.color,
              ),
            ],

            // Central Timer & Sector Tracking Ring
            SafeArea(
              child: Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    ProgressRing(
                      progress: timerState.progress,
                      accentColor: activeColor,
                      size: 270.0,
                      child: TimerDisplay(timerState: timerState),
                    ),
                    AnimatedSectorRing(
                      isActive: timerState.status == TimerStatus.idle,
                      calX: sensorState.calX,
                      calY: sensorState.calY,
                      isDebouncing: sensorState.isDebouncing,
                      targetAngle: getAngleForOrientation(sensorState.pendingOrientation),
                      debounceMs: settings.debounceMs,
                      color: upcomingColor,
                      size: 270.0,
                    ),
                  ],
                ),
              ),
            ),

            // Settings Button (Fixed Top Right)
            SafeArea(
              child: Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: IconButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const SettingsScreen(),
                        ),
                      );
                    },
                    icon: const Icon(LucideIcons.settings2, size: 20),
                    tooltip: 'Settings & Calibration',
                    color: activeColor.withValues(alpha: 0.6),
                  ),
                ),
              ),
            ),

            // Cancel Control (Fixed Bottom Center)
            if (timerState.status != TimerStatus.idle)
              const SafeArea(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 32.0),
                    child: CancelControlSection(),
                  ),
                ),
              ),

            // AOD Pitch Black Overlay (Layered on top when active)
            const AodOverlay(),
          ],
        ),
      ),
    );
  }
}
