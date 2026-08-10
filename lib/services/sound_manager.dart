import 'package:audioplayers/audioplayers.dart';

class SoundManager {
  static final SoundManager _instance = SoundManager._internal();
  factory SoundManager() => _instance;
  SoundManager._internal();

  final AudioPlayer _player = AudioPlayer();
  bool isMuted = false;

  Future<void> playMove() async {
    if (isMuted) return;
    try {
      await _player.stop();
      await _player.play(AssetSource('sounds/move.mp3'));
    } catch (_) {
      // Audio playback fallback safely handled if file is missing in local environment
    }
  }

  Future<void> playCapture() async {
    if (isMuted) return;
    try {
      await _player.stop();
      await _player.play(AssetSource('sounds/capture.mp3'));
    } catch (_) {}
  }

  Future<void> playCheck() async {
    if (isMuted) return;
    try {
      await _player.stop();
      await _player.play(AssetSource('sounds/check.mp3'));
    } catch (_) {}
  }

  Future<void> playVictory() async {
    if (isMuted) return;
    try {
      await _player.stop();
      await _player.play(AssetSource('sounds/victory.mp3'));
    } catch (_) {}
  }

  Future<void> playLowTime() async {
    if (isMuted) return;
    try {
      await _player.stop();
      await _player.play(AssetSource('sounds/low_time.mp3'));
    } catch (_) {}
  }

  void toggleMute() {
    isMuted = !isMuted;
  }
}
