enum Difficulty { easy, medium, hard }

class GameSettings {
  static const Map<Difficulty, int> speedLevels = {
    Difficulty.easy: 800, // Millisekunden
    Difficulty.medium: 500,
    Difficulty.hard: 300,
  };
}
