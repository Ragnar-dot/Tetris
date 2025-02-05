import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';




import 'package:tetris/game_settings.dart';
import 'package:tetris/models/player_score.dart';

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

  static const String _scoresKey = 'tetris_scores';
  static const int maxScores = 8; // Maximale Anzahl der Scores

  static Future<void> saveScore(PlayerScore score) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> scores = prefs.getStringList(_scoresKey) ?? [];

    // Konvertiere alle Scores
    List<PlayerScore> playerScores =
        scores.map((s) => PlayerScore.fromJson(jsonDecode(s))).toList()
          ..add(score) // Füge neuen Score hinzu
          ..sort((a, b) => b.score.compareTo(a.score)); // Sortiere absteigend

    // Behalte nur die besten 8 Scores
    if (playerScores.length > maxScores) {
      playerScores = playerScores.take(maxScores).toList();
    }

    // Speichere die aktualisierten Scores
    await prefs.setStringList(
      _scoresKey,
      playerScores.map((s) => jsonEncode(s.toJson())).toList(),
    );
  }

  static Future<List<PlayerScore>> getScores() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> scores = prefs.getStringList(_scoresKey) ?? [];
    return scores.map((s) => PlayerScore.fromJson(jsonDecode(s))).toList()
      ..sort((a, b) => b.score.compareTo(a.score));
  }

  static Future<void> clearHighscores() async {
    final prefs = await SharedPreferences.getInstance();
    for (var difficulty in Difficulty.values) {
      await prefs.remove(_getKey(difficulty));
    }
  }
}
