import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class AudioService {
  final AudioPlayer _player = AudioPlayer();
  bool enabled = true;

  AudioService();

  void dispose() {
    _player.dispose();
  }

  /// Plays a subtle high chime when locking into a gesture timer.
  Future<void> playLockChime() async {
    if (!enabled) return;
    try {
      final wavBytes = _generateChimeWav(
        frequencies: [880.0, 1320.0],
        durationMs: 250,
      );
      await _player.stop();
      await _player.play(BytesSource(wavBytes));
    } catch (e) {
      debugPrint('Audio chime error: $e');
    }
  }

  /// Plays a distinct power down audio effect on cancellation.
  Future<void> playCancelPowerDown() async {
    if (!enabled) return;
    try {
      final wavBytes = _generatePowerDownWav(
        startFreq: 523.25, // C5
        endFreq: 130.81,   // C3
        durationMs: 350,
      );
      await _player.stop();
      await _player.play(BytesSource(wavBytes));
    } catch (e) {
      debugPrint('Audio power down error: $e');
    }
  }

  /// Plays alarm chime sequence upon timer completion.
  Future<void> playAlarmSequence() async {
    if (!enabled) return;
    try {
      final wavBytes = _generateAlarmWav(durationMs: 2500);
      await _player.stop();
      await _player.play(BytesSource(wavBytes));
    } catch (e) {
      debugPrint('Audio alarm error: $e');
    }
  }

  /// Helper to generate a 16-bit PCM WAV byte buffer in memory.
  static Uint8List _generateChimeWav({
    required List<double> frequencies,
    required int durationMs,
    int sampleRate = 44100,
  }) {
    final int numSamples = (sampleRate * durationMs / 1000).round();
    final int dataSize = numSamples * 2;
    final int fileSize = 36 + dataSize;

    final ByteData bd = ByteData(fileSize + 8);
    // RIFF header
    bd.setUint8(0, 0x52); // 'R'
    bd.setUint8(1, 0x49); // 'I'
    bd.setUint8(2, 0x46); // 'F'
    bd.setUint8(3, 0x46); // 'F'
    bd.setUint32(4, fileSize, Endian.little);
    bd.setUint8(8, 0x57);  // 'W'
    bd.setUint8(9, 0x41);  // 'A'
    bd.setUint8(10, 0x56); // 'V'
    bd.setUint8(11, 0x45); // 'E'

    // fmt subchunk
    bd.setUint8(12, 0x66); // 'f'
    bd.setUint8(13, 0x6D); // 'm'
    bd.setUint8(14, 0x74); // 't'
    bd.setUint8(15, 0x20); // ' '
    bd.setUint32(16, 16, Endian.little); // Subchunk1Size (16 for PCM)
    bd.setUint16(20, 1, Endian.little);  // AudioFormat (1 for PCM)
    bd.setUint16(22, 1, Endian.little);  // NumChannels (1 = Mono)
    bd.setUint32(24, sampleRate, Endian.little);
    bd.setUint32(28, sampleRate * 2, Endian.little); // ByteRate
    bd.setUint16(32, 2, Endian.little);  // BlockAlign
    bd.setUint16(34, 16, Endian.little); // BitsPerSample

    // data subchunk
    bd.setUint8(36, 0x64); // 'd'
    bd.setUint8(37, 0x61); // 'a'
    bd.setUint8(38, 0x74); // 't'
    bd.setUint8(39, 0x61); // 'a'
    bd.setUint32(40, dataSize, Endian.little);

    final int samplePerTone = numSamples ~/ frequencies.length;
    int offset = 44;

    for (int i = 0; i < numSamples; i++) {
      final int toneIdx = min(i ~/ samplePerTone, frequencies.length - 1);
      final double freq = frequencies[toneIdx];
      final double t = i / sampleRate;
      
      final double progressInTone = (i % samplePerTone) / samplePerTone;
      final double envelope = (1.0 - progressInTone) * (1.0 - progressInTone);
      
      final double sampleVal = sin(2 * pi * freq * t) * envelope;
      final int pcm16 = (sampleVal * 28000).clamp(-32768, 32767).toInt();
      bd.setInt16(offset, pcm16, Endian.little);
      offset += 2;
    }

    return bd.buffer.asUint8List();
  }

  static Uint8List _generatePowerDownWav({
    required double startFreq,
    required double endFreq,
    required int durationMs,
    int sampleRate = 44100,
  }) {
    final int numSamples = (sampleRate * durationMs / 1000).round();
    final int dataSize = numSamples * 2;
    final int fileSize = 36 + dataSize;

    final ByteData bd = ByteData(fileSize + 8);
    bd.setUint8(0, 0x52); bd.setUint8(1, 0x49); bd.setUint8(2, 0x46); bd.setUint8(3, 0x46);
    bd.setUint32(4, fileSize, Endian.little);
    bd.setUint8(8, 0x57); bd.setUint8(9, 0x41); bd.setUint8(10, 0x56); bd.setUint8(11, 0x45);
    bd.setUint8(12, 0x66); bd.setUint8(13, 0x6D); bd.setUint8(14, 0x74); bd.setUint8(15, 0x20);
    bd.setUint32(16, 16, Endian.little);
    bd.setUint16(20, 1, Endian.little);
    bd.setUint16(22, 1, Endian.little);
    bd.setUint32(24, sampleRate, Endian.little);
    bd.setUint32(28, sampleRate * 2, Endian.little);
    bd.setUint16(32, 2, Endian.little);
    bd.setUint16(34, 16, Endian.little);
    bd.setUint8(36, 0x64); bd.setUint8(37, 0x61); bd.setUint8(38, 0x74); bd.setUint8(39, 0x61);
    bd.setUint32(40, dataSize, Endian.little);

    int offset = 44;
    double phase = 0.0;

    for (int i = 0; i < numSamples; i++) {
      final double progress = i / numSamples;
      final double currentFreq = startFreq + (endFreq - startFreq) * progress;
      final double envelope = 1.0 - progress;

      phase += 2 * pi * currentFreq / sampleRate;
      final double sampleVal = sin(phase) * envelope;
      final int pcm16 = (sampleVal * 26000).clamp(-32768, 32767).toInt();
      bd.setInt16(offset, pcm16, Endian.little);
      offset += 2;
    }

    return bd.buffer.asUint8List();
  }

  static Uint8List _generateAlarmWav({
    required int durationMs,
    int sampleRate = 44100,
  }) {
    final int numSamples = (sampleRate * durationMs / 1000).round();
    final int dataSize = numSamples * 2;
    final int fileSize = 36 + dataSize;

    final ByteData bd = ByteData(fileSize + 8);
    bd.setUint8(0, 0x52); bd.setUint8(1, 0x49); bd.setUint8(2, 0x46); bd.setUint8(3, 0x46);
    bd.setUint32(4, fileSize, Endian.little);
    bd.setUint8(8, 0x57); bd.setUint8(9, 0x41); bd.setUint8(10, 0x56); bd.setUint8(11, 0x45);
    bd.setUint8(12, 0x66); bd.setUint8(13, 0x6D); bd.setUint8(14, 0x74); bd.setUint8(15, 0x20);
    bd.setUint32(16, 16, Endian.little);
    bd.setUint16(20, 1, Endian.little);
    bd.setUint16(22, 1, Endian.little);
    bd.setUint32(24, sampleRate, Endian.little);
    bd.setUint32(28, sampleRate * 2, Endian.little);
    bd.setUint16(32, 2, Endian.little);
    bd.setUint16(34, 16, Endian.little);
    bd.setUint8(36, 0x64); bd.setUint8(37, 0x61); bd.setUint8(38, 0x74); bd.setUint8(39, 0x61);
    bd.setUint32(40, dataSize, Endian.little);

    final notes = [523.25, 659.25, 783.99, 1046.50];
    final int noteSamples = sampleRate ~/ 5;

    int offset = 44;
    for (int i = 0; i < numSamples; i++) {
      final int noteIdx = (i ~/ noteSamples) % notes.length;
      final double freq = notes[noteIdx];
      final double t = i / sampleRate;
      final double progressInNote = (i % noteSamples) / noteSamples;
      final double envelope = sin(pi * progressInNote);

      final double sampleVal = (sin(2 * pi * freq * t) + 0.3 * sin(4 * pi * freq * t)) * envelope;
      final int pcm16 = (sampleVal * 20000).clamp(-32768, 32767).toInt();
      bd.setInt16(offset, pcm16, Endian.little);
      offset += 2;
    }

    return bd.buffer.asUint8List();
  }
}
