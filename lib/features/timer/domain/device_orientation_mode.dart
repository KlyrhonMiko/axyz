enum DeviceOrientationMode {
  faceUp,        // Neutral resting zone (+Z)
  faceDown,      // Ultimate Focus / AOD (-Z)
  portraitUp,    // Top trigger (-Y)
  portraitDown,  // Bottom trigger (+Y)
  landscapeLeft, // Left trigger (+X)
  landscapeRight,// Right trigger (-X)
  unknown;

  String get label {
    switch (this) {
      case DeviceOrientationMode.faceUp:
        return 'Neutral (Face Up)';
      case DeviceOrientationMode.faceDown:
        return 'Ultimate Focus (Face Down)';
      case DeviceOrientationMode.portraitUp:
        return 'Portrait Up';
      case DeviceOrientationMode.portraitDown:
        return 'Portrait Down';
      case DeviceOrientationMode.landscapeLeft:
        return 'Landscape Left';
      case DeviceOrientationMode.landscapeRight:
        return 'Landscape Right';
      case DeviceOrientationMode.unknown:
        return 'Calibrating...';
    }
  }

  bool get isTrigger {
    return this != DeviceOrientationMode.faceUp && this != DeviceOrientationMode.unknown;
  }
}
