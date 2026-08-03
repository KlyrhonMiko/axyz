import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sensors_plus/sensors_plus.dart';

import '../domain/device_orientation_mode.dart';
import '../domain/sensor_gesture_state.dart';
import '../../settings/providers/settings_provider.dart';

class SensorGestureNotifier extends StateNotifier<SensorGestureState> {
  final Ref _ref;
  StreamSubscription<AccelerometerEvent>? _accelSub;

  Timer? _debounceTimer;
  DateTime? _lastTapTime;
  double _prevZ = 9.8;

  SensorGestureNotifier(this._ref) : super(const SensorGestureState()) {
    _initSensors();
    _ref.onDispose(() {
      _disposeSubscriptions();
    });
  }

  void _disposeSubscriptions() {
    _accelSub?.cancel();
    _debounceTimer?.cancel();
  }

  void _initSensors() {
    try {
      _accelSub = accelerometerEventStream().listen(
        _onAccelerometerEvent,
        onError: (err) => debugPrint('Accelerometer stream error: $err'),
      );
    } catch (e) {
      debugPrint('Failed to initialize accelerometer stream: $e');
    }
  }

  void _onAccelerometerEvent(AccelerometerEvent event) {
    final settings = _ref.read(settingsProvider);

    final rawX = event.x;
    final rawY = event.y;
    final rawZ = event.z;

    // Apply deadzone calibration offset
    final calX = rawX - settings.deadzoneX;
    final calY = rawY - settings.deadzoneY;
    final calZ = rawZ - settings.deadzoneZ;

    // 1. Back Tap Detection (Sharp Z-axis spike)
    if (settings.backTapEnabled) {
      final deltaZ = (calZ - _prevZ).abs();
      if (deltaZ > 13.5) {
        final now = DateTime.now();
        if (_lastTapTime != null) {
          final diffMs = now.difference(_lastTapTime!).inMilliseconds;
          if (diffMs >= 100 && diffMs <= 500) {
            _triggerBackTap();
            _lastTapTime = null;
          } else {
            _lastTapTime = now;
          }
        } else {
          _lastTapTime = now;
        }
      }
    }
    _prevZ = calZ;

    // 2. Determine Orientation from calibrated vectors
    final detectedOrientation = _calculateOrientation(calX, calY, calZ);

    state = state.copyWith(
      rawX: rawX,
      rawY: rawY,
      rawZ: rawZ,
      calX: calX,
      calY: calY,
      calZ: calZ,
    );

    // 3. Process Debounce for Orientation Shifts
    if (detectedOrientation != state.pendingOrientation) {
      _debounceTimer?.cancel();
      state = state.copyWith(
        pendingOrientation: detectedOrientation,
        isDebouncing: true,
      );

      _debounceTimer = Timer(Duration(milliseconds: settings.debounceMs), () {
        state = state.copyWith(
          currentOrientation: detectedOrientation,
          isDebouncing: false,
        );
      });
    }
  }

  DeviceOrientationMode _calculateOrientation(double x, double y, double z) {
    const double threshold = 6.8;

    // Check Z axis first for Face Down / Face Up
    if (z < -threshold) {
      return DeviceOrientationMode.faceDown;
    } else if (z > threshold) {
      return DeviceOrientationMode.faceUp;
    }

    // Check Y axis for Portrait
    if (y < -threshold) {
      return DeviceOrientationMode.portraitUp;
    } else if (y > threshold) {
      return DeviceOrientationMode.portraitDown;
    }

    // Check X axis for Landscape
    if (x > threshold) {
      return DeviceOrientationMode.landscapeLeft;
    } else if (x < -threshold) {
      return DeviceOrientationMode.landscapeRight;
    }

    return state.currentOrientation; // Retain prior state if neutral transition
  }

  // Action callbacks triggered by gestures
  void _triggerBackTap() {
    state = state.copyWith(backTapDetected: true);
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) state = state.copyWith(backTapDetected: false);
    });
  }

  /// Simulated tilt for testing and desktop/emulator support
  void simulateOrientation(DeviceOrientationMode orientation) {
    _debounceTimer?.cancel();
    state = state.copyWith(
      pendingOrientation: orientation,
      isDebouncing: true,
    );

    _debounceTimer = Timer(const Duration(milliseconds: 150), () {
      state = state.copyWith(
        currentOrientation: orientation,
        isDebouncing: false,
      );
    });
  }

  /// Reset simulated tilt to Neutral Face Up
  void simulateResetNeutral() {
    simulateOrientation(DeviceOrientationMode.faceUp);
  }
}

final sensorGestureProvider = StateNotifierProvider<SensorGestureNotifier, SensorGestureState>((ref) {
  return SensorGestureNotifier(ref);
});
