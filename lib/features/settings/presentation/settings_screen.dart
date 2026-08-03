import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../providers/settings_provider.dart';
import '../../timer/providers/sensor_gesture_provider.dart';
import '../../timer/domain/timer_mode.dart';
import '../../../core/constants/app_colors.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final gestureState = ref.watch(sensorGestureProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'CALIBRATION & SETTINGS',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 2.0,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          // Section 1: Deadzone Calibration
          _SectionHeader(
            title: 'ACCELEROMETER CALIBRATION',
            icon: LucideIcons.compass,
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : AppColors.lightCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Flat Surface Offset',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  'Calibrate deadzone offsets to neutralize resting angles caused by camera bumps.',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
                const SizedBox(height: 16),

                // Live Sensor Telemetry
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _TelemetryItem(
                        label: 'RAW X',
                        value: gestureState.rawX.toStringAsFixed(2),
                        cal: gestureState.calX.toStringAsFixed(2),
                      ),
                      _TelemetryItem(
                        label: 'RAW Y',
                        value: gestureState.rawY.toStringAsFixed(2),
                        cal: gestureState.calY.toStringAsFixed(2),
                      ),
                      _TelemetryItem(
                        label: 'RAW Z',
                        value: gestureState.rawZ.toStringAsFixed(2),
                        cal: gestureState.calZ.toStringAsFixed(2),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // Calibrate current readings as neutral flat surface
                          ref.read(settingsProvider.notifier).setDeadzoneCalibration(
                                gestureState.rawX,
                                gestureState.rawY,
                                gestureState.rawZ - 9.80665, // Preserve 1G Earth gravity
                              );
                        },
                        icon: const Icon(LucideIcons.target, size: 16),
                        label: const Text('CALIBRATE NOW'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                          foregroundColor: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      onPressed: () {
                        ref.read(settingsProvider.notifier).resetCalibration();
                      },
                      icon: const Icon(LucideIcons.rotateCcw, size: 18),
                      tooltip: 'Reset Calibration',
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Section 2: Gestures & Cancellation
          _SectionHeader(
            title: 'GESTURES & CANCELLATION',
            icon: LucideIcons.pointer,
          ),
          const SizedBox(height: 8),

          _SwitchTile(
            title: 'Double Back-Tap Cancel',
            subtitle: 'Detect sharp double taps on back of phone',
            value: settings.backTapEnabled,
            onChanged: (val) => ref.read(settingsProvider.notifier).toggleBackTap(val),
          ),

          const SizedBox(height: 16),
          // Debounce Slider
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : AppColors.lightCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Gesture Debounce',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    Text(
                      '${settings.debounceMs} ms',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.accentDeepWork,
                      ),
                    ),
                  ],
                ),
                Slider(
                  value: settings.debounceMs.toDouble(),
                  min: 300.0,
                  max: 800.0,
                  divisions: 10,
                  activeColor: AppColors.accentDeepWork,
                  onChanged: (val) {
                    ref.read(settingsProvider.notifier).setDebounceMs(val.round());
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Section 3: Audio & Feedback
          _SectionHeader(
            title: 'AUDIO & HAPTICS',
            icon: LucideIcons.volume2,
          ),
          const SizedBox(height: 8),

          _SwitchTile(
            title: 'Audio Sound Chimes',
            subtitle: 'Play subtle start chime & power-down sounds',
            value: settings.soundEnabled,
            onChanged: (val) => ref.read(settingsProvider.notifier).toggleSound(val),
          ),
          _SwitchTile(
            title: 'Haptic Feedback',
            subtitle: 'Crisp thud on start & double pulse on cancel',
            value: settings.hapticsEnabled,
            onChanged: (val) => ref.read(settingsProvider.notifier).toggleHaptics(val),
          ),

          const SizedBox(height: 24),

          // Section 4: Mode Durations
          _SectionHeader(
            title: 'TIMER DURATIONS (MINUTES)',
            icon: LucideIcons.clock,
          ),
          const SizedBox(height: 8),

          ...TimerMode.values.map((mode) {
            final duration = settings.modeDurations[mode] ?? mode.defaultDurationMinutes;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : AppColors.lightCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mode.title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        mode.subtitle,
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: duration > 1
                            ? () {
                                ref.read(settingsProvider.notifier).setDuration(mode, duration - 1);
                              }
                            : null,
                        icon: const Icon(LucideIcons.minus, size: 16),
                      ),
                      Text(
                        '$duration m',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      IconButton(
                        onPressed: duration < 180
                            ? () {
                                ref.read(settingsProvider.notifier).setDuration(mode, duration + 1);
                              }
                            : null,
                        icon: const Icon(LucideIcons.plus, size: 16),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.darkTextMuted),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 2.0,
            color: AppColors.darkTextMuted,
          ),
        ),
      ],
    );
  }
}

class _TelemetryItem extends StatelessWidget {
  final String label;
  final String value;
  final String cal;

  const _TelemetryItem({
    required this.label,
    required this.value,
    required this.cal,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.0,
            color: AppColors.darkTextMuted,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontFamily: 'monospace',
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          'Cal: $cal',
          style: const TextStyle(
            fontSize: 10,
            fontFamily: 'monospace',
            color: AppColors.accentDeepWork,
          ),
        ),
      ],
    );
  }
}

class _SwitchTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: SwitchListTile(
          title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          subtitle: Text(
            subtitle,
            style: TextStyle(
              fontSize: 11,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
          ),
          value: value,
          activeTrackColor: AppColors.accentDeepWork,
          onChanged: onChanged,
        ),
      ),
    );
  }
}
