import 'package:flutter/services.dart';

class HapticService {
  /// Trigger a crisp "thud" impact when a timer is locked in via gesture.
  static Future<void> thud() async {
    await HapticFeedback.heavyImpact();
  }

  /// Trigger a distinct double haptic pulse upon successful cancellation.
  static Future<void> cancelPulse() async {
    await HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 120));
    await HapticFeedback.heavyImpact();
  }

  /// Trigger selection feedback during calibration or taps.
  static Future<void> selection() async {
    await HapticFeedback.selectionClick();
  }

  /// Trigger a series of haptic pulses when the timer reaches 00:00.
  static Future<void> alarmSequence() async {
    for (int i = 0; i < 4; i++) {
      await HapticFeedback.vibrate();
      await Future.delayed(const Duration(milliseconds: 250));
      await HapticFeedback.heavyImpact();
      await Future.delayed(const Duration(milliseconds: 250));
    }
  }
}
