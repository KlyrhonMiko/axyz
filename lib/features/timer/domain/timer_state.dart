import 'timer_mode.dart';

enum TimerStatus {
  idle,
  running,
  paused,
  completed;

  bool get isLocked => this == TimerStatus.running || this == TimerStatus.paused;
}

class TimerState {
  final TimerStatus status;
  final TimerMode? activeMode;
  final int totalSeconds;
  final int remainingSeconds;
  final bool isAodActive;
  final String? lastCancelReason;

  const TimerState({
    this.status = TimerStatus.idle,
    this.activeMode,
    this.totalSeconds = 0,
    this.remainingSeconds = 0,
    this.isAodActive = false,
    this.lastCancelReason,
  });

  double get progress {
    if (totalSeconds <= 0) return 0.0;
    return ((totalSeconds - remainingSeconds) / totalSeconds).clamp(0.0, 1.0);
  }

  String get formattedTime {
    final minutes = (remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (remainingSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  TimerState copyWith({
    TimerStatus? status,
    TimerMode? activeMode,
    int? totalSeconds,
    int? remainingSeconds,
    bool? isAodActive,
    String? lastCancelReason,
  }) {
    return TimerState(
      status: status ?? this.status,
      activeMode: activeMode ?? this.activeMode,
      totalSeconds: totalSeconds ?? this.totalSeconds,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      isAodActive: isAodActive ?? this.isAodActive,
      lastCancelReason: lastCancelReason ?? this.lastCancelReason,
    );
  }
}
