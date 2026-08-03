import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../domain/device_orientation_mode.dart';
import '../domain/timer_mode.dart';
import '../domain/timer_state.dart';
import 'sensor_gesture_provider.dart';
import '../../settings/providers/settings_provider.dart';
import '../../../core/audio/audio_service.dart';
import '../../../core/haptics/haptics_service.dart';

final audioServiceProvider = Provider<AudioService>((ref) {
  final audio = AudioService();
  ref.onDispose(() => audio.dispose());
  return audio;
});

class TimerNotifier extends StateNotifier<TimerState> {
  final Ref _ref;
  Timer? _countdownTimer;

  TimerNotifier(this._ref) : super(const TimerState()) {
    _listenToSensorGestures();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _listenToSensorGestures() {
    _ref.listen(sensorGestureProvider, (previous, next) {
      final settings = _ref.read(settingsProvider);
      final audio = _ref.read(audioServiceProvider);
      audio.enabled = settings.soundEnabled;

      // Handle Cancellation Signals while timer is running/paused
      if (state.status.isLocked) {
        // 1. Back Tap Cancellation
        if (next.backTapDetected && settings.backTapEnabled) {
          cancelTimer(reason: 'back_tap');
          return;
        }

        // 2. Proximity Smother Cancellation (held 2 seconds)
        if (next.smotherProgress >= 1.0 && settings.smotherEnabled) {
          cancelTimer(reason: 'smother');
          return;
        }

        // 3. AOD Dynamic Toggle based on physical posture (Face Down = Pitch Black AOD)
        final isFaceDown = (next.currentOrientation == DeviceOrientationMode.faceDown);
        if (isFaceDown != state.isAodActive) {
          state = state.copyWith(isAodActive: isFaceDown);
        }
        return; // STATE LOCK: Ignore orientation trigger changes when running!
      }

      // Handle New Gesture Triggering when Idle or Completed
      if (next.currentOrientation != previous?.currentOrientation && !next.isDebouncing) {
        final targetOrientation = next.currentOrientation;
        if (targetOrientation.isTrigger) {
          final mode = TimerMode.fromOrientation(targetOrientation);
          if (mode != null) {
            startTimer(mode);
          }
        }
      }
    });
  }

  /// Start a new timer for the given mode
  void startTimer(TimerMode mode) {
    _countdownTimer?.cancel();

    final settings = _ref.read(settingsProvider);
    final minutes = settings.modeDurations[mode] ?? mode.defaultDurationMinutes;
    final totalSecs = minutes * 60;

    final isAod = (mode == TimerMode.deepWork ||
        _ref.read(sensorGestureProvider).currentOrientation == DeviceOrientationMode.faceDown);

    state = TimerState(
      status: TimerStatus.running,
      activeMode: mode,
      totalSeconds: totalSecs,
      remainingSeconds: totalSecs,
      isAodActive: isAod,
    );

    // Audio & Haptic Feedback: Start Crisp Thud + Chime
    if (settings.hapticsEnabled) {
      HapticService.thud();
    }
    if (settings.soundEnabled) {
      _ref.read(audioServiceProvider).playLockChime();
    }

    // Keep screen awake while focusing
    WakelockPlus.enable();

    // Start 1-second interval timer
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.remainingSeconds > 1) {
        state = state.copyWith(remainingSeconds: state.remainingSeconds - 1);
      } else {
        _onTimerCompleted();
      }
    });
  }

  /// Pause running timer
  void pauseTimer() {
    if (state.status == TimerStatus.running) {
      _countdownTimer?.cancel();
      state = state.copyWith(status: TimerStatus.paused);
    }
  }

  /// Resume paused timer
  void resumeTimer() {
    if (state.status == TimerStatus.paused) {
      state = state.copyWith(status: TimerStatus.running);
      _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (state.remainingSeconds > 1) {
          state = state.copyWith(remainingSeconds: state.remainingSeconds - 1);
        } else {
          _onTimerCompleted();
        }
      });
    }
  }

  /// Cancel current timer with feedback
  void cancelTimer({required String reason}) {
    _countdownTimer?.cancel();
    final settings = _ref.read(settingsProvider);

    state = state.copyWith(
      status: TimerStatus.idle,
      activeMode: null,
      totalSeconds: 0,
      remainingSeconds: 0,
      isAodActive: false,
      lastCancelReason: reason,
    );

    WakelockPlus.disable();

    // Cancellation Feedback: Double Haptic Pulse + Power Down Chime
    if (settings.hapticsEnabled) {
      HapticService.cancelPulse();
    }
    if (settings.soundEnabled) {
      _ref.read(audioServiceProvider).playCancelPowerDown();
    }
  }

  void _onTimerCompleted() {
    _countdownTimer?.cancel();
    final settings = _ref.read(settingsProvider);

    state = state.copyWith(
      status: TimerStatus.completed,
      remainingSeconds: 0,
      isAodActive: false,
    );

    WakelockPlus.disable();

    // Alarm sequence feedback
    if (settings.hapticsEnabled) {
      HapticService.alarmSequence();
    }
    if (settings.soundEnabled) {
      _ref.read(audioServiceProvider).playAlarmSequence();
    }
  }

  /// Reset completed timer to idle
  void resetToIdle() {
    _countdownTimer?.cancel();
    state = const TimerState();
  }
}

final timerProvider = StateNotifierProvider<TimerNotifier, TimerState>((ref) {
  return TimerNotifier(ref);
});
