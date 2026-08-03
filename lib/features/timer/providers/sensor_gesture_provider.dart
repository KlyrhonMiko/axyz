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
  StreamSubscription<UserAccelerometerEvent>? _userAccelSub;

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
    _userAccelSub?.cancel();
    _debounceTimer?.cancel();
  }

  void _initSensors() {
    try {
      _accelSub = accelerometerEventStream().listen(
        _onAccelerometerEvent,
        onError: (err) => debugPrint('Accelerometer stream error: $err'),
      );
      
      // Use higher sampling rate user accelerometer for tap detection
      _userAccelSub = userAccelerometerEventStream(samplingPeriod: const Duration(milliseconds: 20)).listen(
        _onUserAccelerometerEvent,
        onError: (err) => debugPrint('User Accelerometer stream error: $err'),
      );
    } catch (e) {
      debugPrint('Failed to initialize sensors: $e');
    }
  }

  void _onUserAccelerometerEvent(UserAccelerometerEvent event) {
    final settings = _ref.read(settingsProvider);
    if (!settings.backTapEnabled) return;

    // A tap on the back creates a sharp spike primarily on the Z-axis.
    final zSpike = event.z.abs();
    final xSpike = event.x.abs();
    final ySpike = event.y.abs();
    
    // 1. Keep threshold low (8.0) so natural taps are easy.
    // 2. STRICT purity check: Z must be at least 1.5x larger than X and Y.
    //    A couch drop creates uneven tumbling, so X and Y will be relatively high.
    //    A finger tap is highly focused on the Z axis.
    if (zSpike > 8.0 && zSpike > (xSpike * 1.5) && zSpike > (ySpike * 1.5)) { 
      final now = DateTime.now();
      if (_lastTapTime != null) {
        final diffMs = now.difference(_lastTapTime!).inMilliseconds;
        // 3. Tighten max gap to 400ms. A bounce on a couch is often a slow, 
        //    lofty airborne bounce. A double tap is typically fast (100-300ms).
        if (diffMs >= 100 && diffMs <= 400) {
          _triggerBackTap();
          _lastTapTime = null;
        } else {
          // Ringing / bouncing filter
          _lastTapTime = now;
        }
      } else {
        _lastTapTime = now;
      }
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

    // 2. Determine Orientation from calibrated vectors
    final detectedOrientation = _calculateOrientation(calX, calY, calZ);

    // Apply a noise filter: only update if change is significant or orientation changed
    // This prevents flooding the UI with rebuilds from microscopic sensor jitter when idle
    final diffX = (calX - state.calX).abs();
    final diffY = (calY - state.calY).abs();
    final diffZ = (calZ - state.calZ).abs();
    
    if (diffX < 0.1 && diffY < 0.1 && diffZ < 0.1 && detectedOrientation == state.pendingOrientation) {
      return;
    }

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
