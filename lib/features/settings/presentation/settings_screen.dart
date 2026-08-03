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

    final primaryTextColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final secondaryTextColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final backgroundColor = isDark ? AppColors.darkBackground : AppColors.lightBackground;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Settings',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: primaryTextColor,
            letterSpacing: 0.5,
          ),
        ),
        iconTheme: IconThemeData(color: primaryTextColor),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        children: [
          // Section 1: Deadzone Calibration
          const _SectionHeader(title: 'Calibration'),
          const SizedBox(height: 16),
          
          Text(
            'Calibrate resting offsets to neutralize angled camera bumps.',
            style: TextStyle(
              fontSize: 14,
              height: 1.4,
              color: secondaryTextColor,
            ),
          ),
          const SizedBox(height: 24),
          
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    ref.read(settingsProvider.notifier).setDeadzoneCalibration(
                          gestureState.rawX,
                          gestureState.rawY,
                          gestureState.rawZ - 9.80665, // Preserve 1G Earth gravity
                        );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: primaryTextColor,
                    side: BorderSide(
                      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                      width: 1,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Calibrate Flat Surface', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                onPressed: () {
                  ref.read(settingsProvider.notifier).resetCalibration();
                },
                icon: const Icon(LucideIcons.rotateCcw, size: 20),
                color: secondaryTextColor,
                tooltip: 'Reset Calibration',
              ),
            ],
          ),
          
          const SizedBox(height: 48),

          // Section 2: Gestures
          const _SectionHeader(title: 'Gestures'),
          const SizedBox(height: 16),

          _SettingRow(
            title: 'Double Back-Tap Cancel',
            subtitle: 'Detect sharp taps on the back of phone',
            trailing: Switch.adaptive(
              value: settings.backTapEnabled,
              activeColor: AppColors.accentDeepWork,
              onChanged: (val) => ref.read(settingsProvider.notifier).toggleBackTap(val),
            ),
          ),
          const SizedBox(height: 24),
          
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Gesture Debounce',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: primaryTextColor),
                  ),
                  Text(
                    '${settings.debounceMs} ms',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: secondaryTextColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SliderTheme(
                data: SliderThemeData(
                  trackHeight: 2,
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                  overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
                  activeTrackColor: AppColors.accentDeepWork,
                  inactiveTrackColor: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  thumbColor: AppColors.accentDeepWork,
                ),
                child: Slider(
                  value: settings.debounceMs.toDouble(),
                  min: 300.0,
                  max: 800.0,
                  divisions: 10,
                  onChanged: (val) {
                    ref.read(settingsProvider.notifier).setDebounceMs(val.round());
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 48),

          // Section 3: Audio & Feedback
          const _SectionHeader(title: 'Audio & Haptics'),
          const SizedBox(height: 16),

          _SettingRow(
            title: 'Sound Chimes',
            subtitle: 'Subtle start & stop sounds',
            trailing: Switch.adaptive(
              value: settings.soundEnabled,
              activeColor: AppColors.accentDeepWork,
              onChanged: (val) => ref.read(settingsProvider.notifier).toggleSound(val),
            ),
          ),
          const SizedBox(height: 16),
          _SettingRow(
            title: 'Haptic Feedback',
            subtitle: 'Crisp vibrations on actions',
            trailing: Switch.adaptive(
              value: settings.hapticsEnabled,
              activeColor: AppColors.accentDeepWork,
              onChanged: (val) => ref.read(settingsProvider.notifier).toggleHaptics(val),
            ),
          ),

          const SizedBox(height: 48),

          // Section 4: Timer Durations
          const _SectionHeader(title: 'Timer Durations'),
          const SizedBox(height: 16),

          ...TimerMode.values.map((mode) {
            final duration = settings.modeDurations[mode] ?? mode.defaultDurationMinutes;
            return Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          mode.title,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: primaryTextColor,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          mode.subtitle,
                          style: TextStyle(
                            fontSize: 13,
                            color: secondaryTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      _MinimalIconButton(
                        icon: LucideIcons.minus,
                        onPressed: duration > 1
                            ? () => ref.read(settingsProvider.notifier).setDuration(mode, duration - 1)
                            : null,
                      ),
                      SizedBox(
                        width: 48,
                        child: Text(
                          '$duration m',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: primaryTextColor,
                          ),
                        ),
                      ),
                      _MinimalIconButton(
                        icon: LucideIcons.plus,
                        onPressed: duration < 180
                            ? () => ref.read(settingsProvider.notifier).setDuration(mode, duration + 1)
                            : null,
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

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Text(
      title,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.2,
        color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
      ),
    );
  }
}

class _SettingRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget trailing;

  const _SettingRow({
    required this.title,
    required this.subtitle,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        trailing,
      ],
    );
  }
}

class _MinimalIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;

  const _MinimalIconButton({required this.icon, this.onPressed});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      color: color,
      disabledColor: color.withOpacity(0.2),
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
    );
  }
}
