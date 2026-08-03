import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/settings_state.dart';
import '../../timer/domain/timer_mode.dart';

class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier() : super(const SettingsState());

  void setDeadzoneCalibration(double x, double y, double z) {
    state = state.copyWith(
      deadzoneX: x,
      deadzoneY: y,
      deadzoneZ: z,
    );
  }

  void resetCalibration() {
    state = state.copyWith(
      deadzoneX: 0.0,
      deadzoneY: 0.0,
      deadzoneZ: 0.0,
    );
  }

  void toggleSound(bool value) {
    state = state.copyWith(soundEnabled: value);
  }

  void toggleHaptics(bool value) {
    state = state.copyWith(hapticsEnabled: value);
  }

  void toggleBackTap(bool value) {
    state = state.copyWith(backTapEnabled: value);
  }


  void setDebounceMs(int value) {
    state = state.copyWith(debounceMs: value);
  }

  void setDuration(TimerMode mode, int minutes) {
    final updated = Map<TimerMode, int>.from(state.modeDurations);
    updated[mode] = minutes;
    state = state.copyWith(modeDurations: updated);
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier();
});
