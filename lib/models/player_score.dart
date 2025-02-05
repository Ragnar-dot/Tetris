import 'package:tetris/game_settings.dart';

class PlayerScore {
  final String playerName;
  final int score;
  final DateTime date;
  final Difficulty difficulty;

  PlayerScore({
    required this.playerName,
    required this.score,
    required this.date,
    required this.difficulty,
  });

  Map<String, dynamic> toJson() => {
        'playerName': playerName,
        'score': score,
        'date': date.toIso8601String(),
        'difficulty': difficulty.toString(),
      };

  factory PlayerScore.fromJson(Map<String, dynamic> json) => PlayerScore(
        playerName: json['playerName'],
        score: json['score'],
        date: DateTime.parse(json['date']),
        difficulty: Difficulty.values.firstWhere(
          (d) => d.toString() == json['difficulty'],
        ),
      );
}
