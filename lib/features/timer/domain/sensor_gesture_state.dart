import 'device_orientation_mode.dart';

class SensorGestureState {
  final DeviceOrientationMode currentOrientation;
  final DeviceOrientationMode pendingOrientation;
  final double rawX;
  final double rawY;
  final double rawZ;
  final double calX;
  final double calY;
  final double calZ;
  final bool isNear;
  final double smotherProgress; // 0.0 to 1.0 (2 seconds)
  final bool backTapDetected;
  final bool isDebouncing;

  const SensorGestureState({
    this.currentOrientation = DeviceOrientationMode.faceUp,
    this.pendingOrientation = DeviceOrientationMode.faceUp,
    this.rawX = 0.0,
    this.rawY = 0.0,
    this.rawZ = 9.8,
    this.calX = 0.0,
    this.calY = 0.0,
    this.calZ = 9.8,
    this.isNear = false,
    this.smotherProgress = 0.0,
    this.backTapDetected = false,
    this.isDebouncing = false,
  });

  SensorGestureState copyWith({
    DeviceOrientationMode? currentOrientation,
    DeviceOrientationMode? pendingOrientation,
    double? rawX,
    double? rawY,
    double? rawZ,
    double? calX,
    double? calY,
    double? calZ,
    bool? isNear,
    double? smotherProgress,
    bool? backTapDetected,
    bool? isDebouncing,
  }) {
    return SensorGestureState(
      currentOrientation: currentOrientation ?? this.currentOrientation,
      pendingOrientation: pendingOrientation ?? this.pendingOrientation,
      rawX: rawX ?? this.rawX,
      rawY: rawY ?? this.rawY,
      rawZ: rawZ ?? this.rawZ,
      calX: calX ?? this.calX,
      calY: calY ?? this.calY,
      calZ: calZ ?? this.calZ,
      isNear: isNear ?? this.isNear,
      smotherProgress: smotherProgress ?? this.smotherProgress,
      backTapDetected: backTapDetected ?? this.backTapDetected,
      isDebouncing: isDebouncing ?? this.isDebouncing,
    );
  }
}
