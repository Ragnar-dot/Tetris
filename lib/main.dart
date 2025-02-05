import 'dart:async';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:provider/provider.dart';

// Privat Imports
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:tetris/game_settings.dart';
import 'package:tetris/highscore_service.dart';
import 'package:tetris/tetromino.dart';
import 'package:tetris/game_music_controller.dart';
import 'package:tetris/models/player_score.dart';
import 'package:tetris/screens/welcome_screen.dart';
import 'package:tetris/screens/hall_of_fame.dart';
import 'package:tetris/providers/highscore_notifier.dart';

void main() {
  runApp(const TetrisApp());
}

class TetrisApp extends StatelessWidget {
  const TetrisApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HighscoreNotifier(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          primaryColor: Colors.blue,
        ),
        home: const WelcomeScreen(),
      ),
    );
  }
}

class TetrisHomePage extends StatefulWidget {
  final String playerName;

  const TetrisHomePage({
    super.key,
    required this.playerName,
  });

  @override
  State<TetrisHomePage> createState() => _TetrisHomePageState();
}

class _TetrisHomePageState extends State<TetrisHomePage> {
  static const int rows = 20;
  static const int cols = 10;

  List<List<Color>> board = List.generate(
    rows,
    (_) => List.generate(cols, (_) => Colors.black12),
  );

  Tetromino? currentPiece;
  Tetromino? nextPiece;
  Timer? gameTimer;
  int score = 0;
  int highscore = 0;
  bool isGameOver = false;
  Difficulty difficulty = Difficulty.medium;
  final AudioPlayer audioPlayer = AudioPlayer();
  final GameMusicController _musicController = GameMusicController();
  bool isPaused = false;

  @override
  void initState() {
    super.initState();
    _initializeMusic();
    context.read<HighscoreNotifier>().loadHighscore();
    startGame();
  }

  Future<void> _initializeMusic() async {
    await _musicController.initialize();
    _musicController.play();
  }

  void startGame() {
    currentPiece = generateNewPiece();
    nextPiece = generateNewPiece();
    gameTimer = Timer.periodic(
        Duration(milliseconds: GameSettings.speedLevels[difficulty]!),
        (timer) => gameLoop());
  }

  void playSound(String soundEffect) async {
    await audioPlayer.play(AssetSource('sounds/$soundEffect.mp3'));
  }

  void gameLoop() {
    setState(() {
      if (!canMoveDown()) {
        placePiece();
        playSound('place');
        int clearedLines = clearLines();
        if (clearedLines > 0) {
          playSound('clear');
          score += clearedLines * 100 * clearedLines;
        }
        currentPiece = nextPiece;
        nextPiece = generateNewPiece();
        if (!isValidPosition(currentPiece!)) {
          gameOver();
        }
      } else {
        currentPiece!.moveDown();
      }
    });
  }

  void togglePause() {
    setState(() {
      isPaused = !isPaused;
      if (isPaused) {
        gameTimer?.cancel();
        _musicController.pause();
      } else {
        gameTimer = Timer.periodic(
          Duration(milliseconds: GameSettings.speedLevels[difficulty]!),
          (timer) => gameLoop(),
        );
        _musicController.play();
      }
    });
  }

  Widget _buildGameWrapper(Widget gameContent) {
    return RawKeyboardListener(
      focusNode: FocusNode(),
      autofocus: true,
      onKey: (RawKeyEvent event) {
        if (event is RawKeyDownEvent) {
          if (event.repeat) {
            if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
              setState(() {
                while (canMoveDown()) {
                  currentPiece?.moveDown();
                }
                playSound('drop');
              });
            }
            return;
          }

          setState(() {
            switch (event.logicalKey) {
              case LogicalKeyboardKey.arrowLeft:
                if (canMove(-1)) {
                  currentPiece?.moveLeft();
                  playSound('move');
                }
                break;
              case LogicalKeyboardKey.arrowRight:
                if (canMove(1)) {
                  currentPiece?.moveRight();
                  playSound('move');
                }
                break;
              case LogicalKeyboardKey.arrowUp:
                rotatePiece();
                playSound('rotate');
                break;
              case LogicalKeyboardKey.arrowDown:
                if (canMoveDown()) {
                  currentPiece?.moveDown();
                }
                break;
              case LogicalKeyboardKey.space:
                while (canMoveDown()) {
                  currentPiece?.moveDown();
                }
                playSound('drop');
                break;
            }
          });
        }
      },
      child: gameContent,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = Theme.of(context).platform == TargetPlatform.iOS ||
        Theme.of(context).platform == TargetPlatform.android;

    Widget gameContent = Scaffold(
      appBar: AppBar(
        title: Text('Tetris - Score: $score'),
        actions: [
          IconButton(
            icon: Icon(isPaused ? Icons.play_arrow : Icons.pause),
            onPressed: togglePause,
          ),
          IconButton(
            icon: const Icon(Icons.volume_up),
            onPressed: _musicController.toggleMute,
          ),
          PopupMenuButton<Difficulty>(
            initialValue: difficulty,
            onSelected: (Difficulty newDifficulty) {
              setState(() {
                difficulty = newDifficulty;
                gameTimer?.cancel();
                context.read<HighscoreNotifier>().loadHighscore();
                startGame();
              });
            },
            itemBuilder: (BuildContext context) => Difficulty.values
                .map((d) => PopupMenuItem<Difficulty>(
                      value: d,
                      child: Text(d.toString().split('.').last),
                    ))
                .toList(),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(1.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Consumer<HighscoreNotifier>(
                  builder: (context, highscoreNotifier, child) => Text(
                    'Highscore: ${highscoreNotifier.currentHighscore}',
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(1),
                  ),
                  child: nextPiece != null
                      ? GridView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                          ),
                          itemCount: 16,
                          itemBuilder: (context, index) {
                            final row = index ~/ 4;
                            final col = index % 4;
                            Color cellColor = Colors.black12;
                            if (row < nextPiece!.shape.length &&
                                col < nextPiece!.shape[0].length) {
                              if (nextPiece!.shape[row][col] == 1) {
                                cellColor = nextPiece!.color;
                              }
                            }
                            return Container(
                              decoration: BoxDecoration(
                                color: cellColor,
                                border: Border.all(
                                    color: const Color.fromARGB(254, 0, 0, 0)),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            );
                          },
                        )
                      : null,
                ),
              ],
            ),
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                double cellSizeFromWidth = constraints.maxWidth / cols;
                double cellSizeFromHeight = constraints.maxHeight / rows;
                double cellSize = cellSizeFromWidth < cellSizeFromHeight
                    ? cellSizeFromWidth
                    : cellSizeFromHeight;

                return Center(
                  child: SizedBox(
                    width: cellSize * cols,
                    height: cellSize * rows,
                    child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: cols,
                      ),
                      itemCount: rows * cols,
                      itemBuilder: (context, index) {
                        final row = index ~/ cols;
                        final col = index % cols;
                        Color cellColor = board[row][col];

                        if (currentPiece != null) {
                          if (row >= currentPiece!.y &&
                              row <
                                  currentPiece!.y +
                                      currentPiece!.shape.length &&
                              col >= currentPiece!.x &&
                              col <
                                  currentPiece!.x +
                                      currentPiece!.shape[0].length) {
                            if (currentPiece!.shape[row - currentPiece!.y]
                                    [col - currentPiece!.x] ==
                                1) {
                              cellColor = currentPiece!.color;
                            }
                          }
                        }

                        return Container(
                          decoration: BoxDecoration(
                            color: cellColor,
                            border: Border.all(
                                color: const Color.fromARGB(255, 0, 0, 0)),
                            borderRadius: BorderRadius.circular(4),
                            boxShadow: [
                              if (cellColor !=
                                  const Color.fromARGB(144, 0, 0, 0))
                                BoxShadow(
                                  color: cellColor.withOpacity(0.3),
                                  blurRadius: 4,
                                  spreadRadius: 1,
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
          if (isMobile)
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(20),
                    ),
                    onPressed: () {
                      setState(() {
                        if (canMove(-1)) {
                          currentPiece?.moveLeft();
                          playSound('move');
                        }
                      });
                    },
                    child: const Icon(Icons.arrow_left),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(20),
                    ),
                    onPressed: () {
                      setState(() {
                        rotatePiece();
                        playSound('rotate');
                      });
                    },
                    child: const Icon(Icons.rotate_right),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(20),
                    ),
                    onPressed: () {
                      setState(() {
                        if (canMove(1)) {
                          currentPiece?.moveRight();
                          playSound('move');
                        }
                      });
                    },
                    child: const Icon(Icons.arrow_right),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(20),
                    ),
                    onPressed: () {
                      setState(() {
                        while (canMoveDown()) {
                          currentPiece?.moveDown();
                        }
                        playSound('drop');
                      });
                    },
                    child: const Icon(Icons.arrow_drop_down),
                  ),
                ],
              ),
            ),
        ],
      ),
    );

    return isMobile ? gameContent : _buildGameWrapper(gameContent);
  }

  void gameOver() async {
    _musicController.stop();
    gameTimer?.cancel();
    isGameOver = true;
    updateHighscore(score);
    await HighscoreService.saveScore(PlayerScore(
      playerName: widget.playerName,
      score: score,
      date: DateTime.now(),
      difficulty: difficulty,
    ));
    playSound('gameover');

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Game Over'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Score: $score'),
            Text('Highscore: $highscore'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final scores = await HighscoreService.getScores();
              if (!mounted) return;
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => HallOfFame(
                    scores: scores,
                    onRestart: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => TetrisHomePage(
                            playerName: widget.playerName,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
            child: const Text('Hall of Fame'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              resetGame();
            },
            child: const Text('Neu starten'),
          ),
        ],
      ),
    );
  }

  void resetGame() {
    setState(() {
      board = List.generate(
        rows,
        (_) => List.generate(cols, (_) => Colors.black12),
      );
      currentPiece = null;
      nextPiece = null;
      score = 0;
      highscore = 0;
      isGameOver = false;
      _musicController.play();
      startGame();
      context.read<HighscoreNotifier>().loadHighscore();
    });
  }

  bool canMove(int dx) {
    if (currentPiece == null) return false;
    return isValidPosition(Tetromino(
      currentPiece!.type,
      x: currentPiece!.x + dx,
      y: currentPiece!.y,
      shape: currentPiece!.shape,
      color: currentPiece!.color,
    ));
  }

  bool canMoveDown() {
    if (currentPiece == null) return false;
    return isValidPosition(Tetromino(
      currentPiece!.type,
      x: currentPiece!.x,
      y: currentPiece!.y + 1,
      shape: currentPiece!.shape,
      color: currentPiece!.color,
    ));
  }

  bool isValidPosition(Tetromino piece) {
    if (piece.y + piece.shape.length > rows ||
        piece.x < 0 ||
        piece.x + piece.shape[0].length > cols ||
        piece.y < 0) {
      return false;
    }

    return !isCollision(piece);
  }

  bool isCollision(Tetromino piece) {
    for (int row = 0; row < piece.shape.length; row++) {
      for (int col = 0; col < piece.shape[0].length; col++) {
        if (piece.shape[row][col] == 1) {
          if (board[piece.y + row][piece.x + col] != Colors.black12) {
            return true;
          }
        }
      }
    }
    return false;
  }

  void placePiece() {
    if (currentPiece != null) {
      for (int row = 0; row < currentPiece!.shape.length; row++) {
        for (int col = 0; col < currentPiece!.shape[0].length; col++) {
          if (currentPiece!.shape[row][col] == 1) {
            board[currentPiece!.y + row][currentPiece!.x + col] =
                currentPiece!.color;
          }
        }
      }
      _musicController.updateSpeed(_countBlocks());
    }
  }

  int clearLines() {
    int clearedLines = 0;
    for (int row = 0; row < rows; row++) {
      if (board[row].every((cell) => cell != Colors.black12)) {
        board.removeAt(row);
        board.insert(0, List.filled(cols, Colors.black12));
        clearedLines++;
      }
    }
    return clearedLines;
  }

  int _countBlocks() {
    int count = 0;
    for (var row in board) {
      for (var cell in row) {
        if (cell != Colors.black12) {
          count++;
        }
      }
    }
    return count;
  }

  void rotatePiece() {
    if (currentPiece != null) {
      currentPiece = Tetromino(
        currentPiece!.type,
        x: currentPiece!.x,
        y: currentPiece!.y,
        shape: rotateShape(currentPiece!.shape),
        color: currentPiece!.color,
      );
    }
  }

  List<List<int>> rotateShape(List<List<int>> shape) {
    int rows = shape.length;
    int cols = shape[0].length;
    List<List<int>> rotated = List.generate(cols, (_) => List.filled(rows, 0));
    for (int row = 0; row < rows; row++) {
      for (int col = 0; col < cols; col++) {
        rotated[col][rows - 1 - row] = shape[row][col];
      }
    }
    return rotated;
  }

  Tetromino generateNewPiece() {
    return Tetromino(
        TetrominoType.values[Random().nextInt(TetrominoType.values.length)]);
  }

  void updateHighscore(int newScore) {
    context.read<HighscoreNotifier>().updateHighscore(newScore, difficulty);
    setState(() {
      highscore = context.read<HighscoreNotifier>().currentHighscore;
    });
  }

  @override
  void dispose() {
    _musicController.dispose();
    super.dispose();
  }
}
