import 'package:vibration/vibration.dart';

class HapticManager {
  static final HapticManager _instance = HapticManager._internal();
  factory HapticManager() => _instance;
  HapticManager._internal();

  bool isEnabled = true;

  Future<void> vibrateLight() async {
    if (!isEnabled) return;
    final hasVibrator = await Vibration.hasVibrator();
    if (hasVibrator ?? false) {
      Vibration.vibrate(duration: 30, amplitude: 50);
    }
  }

  Future<void> vibrateMedium() async {
    if (!isEnabled) return;
    final hasVibrator = await Vibration.hasVibrator();
    if (hasVibrator ?? false) {
      Vibration.vibrate(duration: 70, amplitude: 128);
    }
  }

  Future<void> vibrateHeavy() async {
    if (!isEnabled) return;
    final hasVibrator = await Vibration.hasVibrator();
    if (hasVibrator ?? false) {
      Vibration.vibrate(duration: 150, amplitude: 255);
    }
  }
}
