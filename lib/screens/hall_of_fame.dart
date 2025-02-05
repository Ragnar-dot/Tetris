import 'package:flutter/material.dart';
import 'package:tetris/models/player_score.dart';

class HallOfFame extends StatelessWidget {
  final List<PlayerScore> scores;
  final VoidCallback onRestart;

  const HallOfFame({
    super.key,
    required this.scores,
    required this.onRestart,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.purple,
              Colors.blue,
              Colors.teal,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(20.0),
                child: Text(
                  'Hall of Fame',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 224, 224, 224),
                    shadows: [
                      Shadow(
                        color: Colors.black54,
                        offset: Offset(2, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: scores.length,
                  itemBuilder: (context, index) {
                    final score = scores[index];
                    final isTopThree = index < 3;

                    return Card(
                      elevation: isTopThree ? 8 : 2,
                      margin: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 4,
                      ),
                      color: isTopThree
                          ? [
                              Colors.amber,
                              Colors.grey[300],
                              Colors.brown[300],
                              const Color.fromARGB(255, 121, 66, 46),
                              const Color.fromARGB(255, 25, 137, 122),
                              const Color.fromARGB(255, 136, 45, 159)
                            ][index]
                          : const Color.fromARGB(255, 150, 150, 150),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.blue.withOpacity(0.8),
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(
                              color: Color.fromARGB(255, 0, 0, 0),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          score.playerName,
                          style: TextStyle(
                            color: const Color.fromARGB(255, 0, 0, 0),
                            fontWeight: isTopThree
                                ? FontWeight.bold
                                : FontWeight.normal,
                            fontSize: isTopThree ? 18 : 16,
                          ),
                        ),
                        subtitle: Text(
                          'Difficulty: ${score.difficulty.name}',
                          style: TextStyle(
                            color:
                                isTopThree ? Colors.black87 : Colors.grey[600],
                          ),
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${score.score}',
                              style: TextStyle(
                                fontSize: isTopThree ? 20 : 16,
                                fontWeight: FontWeight.bold,
                                color: isTopThree
                                    ? Colors.black
                                    : Colors.grey[800],
                              ),
                            ),
                            Text(
                              score.date.toString().substring(0, 10),
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: ElevatedButton(
                  onPressed: onRestart,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 15,
                    ),
                    backgroundColor: const Color.fromARGB(255, 0, 0, 0),
                  ),
                  child: const Text(
                    'Neues Spiel',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
