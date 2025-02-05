import 'package:tetris/game_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HighscoreService {
  static String _getKey(Difficulty difficulty) =>
      'tetris_highscore_${difficulty.name}';

  static Future<void> saveHighscore(int score, Difficulty difficulty) async {
    final prefs = await SharedPreferences.getInstance();
    final currentHighscore = prefs.getInt(_getKey(difficulty)) ?? 0;
    if (score > currentHighscore) {
      await prefs.setInt(_getKey(difficulty), score);
    }
  }

  static Future<int> getHighscore(Difficulty difficulty) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_getKey(difficulty)) ?? 0;
  }

  static Future<Map<Difficulty, int>> getAllHighscores() async {
    final prefs = await SharedPreferences.getInstance();
    Map<Difficulty, int> scores = {};
    for (var difficulty in Difficulty.values) {
      scores[difficulty] = prefs.getInt(_getKey(difficulty)) ?? 0;
    }
    return scores;
  }
}
