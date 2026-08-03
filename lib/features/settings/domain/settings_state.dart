import '../../timer/domain/timer_mode.dart';

class SettingsState {
  final double deadzoneX;
  final double deadzoneY;
  final double deadzoneZ;
  final bool soundEnabled;
  final bool hapticsEnabled;
  final bool backTapEnabled;
  final bool smotherEnabled;
  final int debounceMs;
  final Map<TimerMode, int> modeDurations;

  const SettingsState({
    this.deadzoneX = 0.0,
    this.deadzoneY = 0.0,
    this.deadzoneZ = 0.0,
    this.soundEnabled = true,
    this.hapticsEnabled = true,
    this.backTapEnabled = true,
    this.smotherEnabled = true,
    this.debounceMs = 400,
    this.modeDurations = const {
      TimerMode.deepWork: 60,
      TimerMode.pomodoro: 25,
      TimerMode.shortBreak: 5,
      TimerMode.longBreak: 15,
      TimerMode.customFocus: 45,
    },
  });

  SettingsState copyWith({
    double? deadzoneX,
    double? deadzoneY,
    double? deadzoneZ,
    bool? soundEnabled,
    bool? hapticsEnabled,
    bool? backTapEnabled,
    bool? smotherEnabled,
    int? debounceMs,
    Map<TimerMode, int>? modeDurations,
  }) {
    return SettingsState(
      deadzoneX: deadzoneX ?? this.deadzoneX,
      deadzoneY: deadzoneY ?? this.deadzoneY,
      deadzoneZ: deadzoneZ ?? this.deadzoneZ,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
      backTapEnabled: backTapEnabled ?? this.backTapEnabled,
      smotherEnabled: smotherEnabled ?? this.smotherEnabled,
      debounceMs: debounceMs ?? this.debounceMs,
      modeDurations: modeDurations ?? this.modeDurations,
    );
  }
}
