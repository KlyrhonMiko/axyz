import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import 'device_orientation_mode.dart';

enum TimerMode {
  deepWork(
    title: 'Deep Work',
    subtitle: 'Ultimate Focus (Face Down)',
    defaultDurationMinutes: 60,
    triggerOrientation: DeviceOrientationMode.faceDown,
    color: AppColors.accentDeepWork,
  ),
  pomodoro(
    title: 'Pomodoro',
    subtitle: 'Standard Sprint (Portrait Up)',
    defaultDurationMinutes: 25,
    triggerOrientation: DeviceOrientationMode.portraitUp,
    color: AppColors.accentPomodoro,
  ),
  shortBreak(
    title: 'Short Break',
    subtitle: 'Quick Refresh (Portrait Down)',
    defaultDurationMinutes: 5,
    triggerOrientation: DeviceOrientationMode.portraitDown,
    color: AppColors.accentShortBreak,
  ),
  longBreak(
    title: 'Long Break',
    subtitle: 'Extended Rest (Landscape Left)',
    defaultDurationMinutes: 15,
    triggerOrientation: DeviceOrientationMode.landscapeLeft,
    color: AppColors.accentLongBreak,
  ),
  customFocus(
    title: 'Deep Sprint',
    subtitle: 'Extended Session (Landscape Right)',
    defaultDurationMinutes: 45,
    triggerOrientation: DeviceOrientationMode.landscapeRight,
    color: AppColors.accentFocus,
  );

  final String title;
  final String subtitle;
  final int defaultDurationMinutes;
  final DeviceOrientationMode triggerOrientation;
  final Color color;

  const TimerMode({
    required this.title,
    required this.subtitle,
    required this.defaultDurationMinutes,
    required this.triggerOrientation,
    required this.color,
  });

  static TimerMode? fromOrientation(DeviceOrientationMode mode) {
    for (final timerMode in TimerMode.values) {
      if (timerMode.triggerOrientation == mode) return timerMode;
    }
    return null;
  }
}
