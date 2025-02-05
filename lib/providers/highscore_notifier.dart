import 'package:flutter/foundation.dart';




import 'package:tetris/game_settings.dart';
import 'package:tetris/highscore_service.dart';

class HighscoreNotifier extends ChangeNotifier {
  int _currentHighscore = 0;
  Difficulty _currentDifficulty = Difficulty.medium;

  int get currentHighscore => _currentHighscore;

  Future<void> updateHighscore(int newScore, Difficulty difficulty) async {
    if (difficulty != _currentDifficulty) {
      _currentDifficulty = difficulty;
      await loadHighscore();
    }

    if (newScore > _currentHighscore) {
      _currentHighscore = newScore;
      await HighscoreService.saveHighscore(newScore, difficulty);
      notifyListeners();
    }
  }

  Future<void> loadHighscore() async {
    final scores = await HighscoreService.getScores();
    if (scores.isNotEmpty) {
      final highestScore = scores
          .where((score) => score.difficulty == _currentDifficulty)
          .fold(0, (max, score) => score.score > max ? score.score : max);
      _currentHighscore = highestScore;
      notifyListeners();
    }
  }
}
