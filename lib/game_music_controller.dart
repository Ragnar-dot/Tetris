import 'package:audioplayers/audioplayers.dart';

class GameMusicController {
  final AudioPlayer _musicPlayer = AudioPlayer();
  double _currentSpeed = 1.0;
  bool _isMuted = false;

  Future<void> initialize() async {
    await _musicPlayer.setSource(AssetSource('sounds/game_music.mp3'));
    await _musicPlayer.setReleaseMode(ReleaseMode.loop);
    _currentSpeed = 1.0;
    await _musicPlayer.setPlaybackRate(_currentSpeed);
  }

  void play() {
    if (!_isMuted) {
      _musicPlayer.resume();
    }
  }

  void pause() {
    _musicPlayer.pause();
  }

  void stop() {
    _musicPlayer.stop();
  }

  void updateSpeed(int blockCount) {
    // Geschwindigkeit basierend auf der Anzahl der Blöcke anpassen
    double newSpeed = 1.0;
    if (blockCount > 150) {
      newSpeed = 1.5;
    } else if (blockCount > 100) {
      newSpeed = 1.3;
    } else if (blockCount > 50) {
      newSpeed = 1.15;
    }

    if (newSpeed != _currentSpeed) {
      _currentSpeed = newSpeed;
      _musicPlayer.setPlaybackRate(_currentSpeed);
    }
  }

  void toggleMute() {
    _isMuted = !_isMuted;
    if (_isMuted) {
      pause();
    } else {
      play();
    }
  }

  void dispose() {
    _musicPlayer.dispose();
  }
}
