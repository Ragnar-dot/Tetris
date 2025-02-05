import 'package:flutter/material.dart';

enum TetrominoType { I, O, T, S, Z, J, L }

class Tetromino {
  final TetrominoType type;
  List<List<int>> shape;
  Color color;
  int x;
  int y;

  Tetromino(this.type,
      {this.x = 3, this.y = 0, List<List<int>>? shape, Color? color})
      : shape = shape ?? _getDefaultShape(type),
        color = color ?? _getDefaultColor(type);

  static List<List<int>> _getDefaultShape(TetrominoType type) {
    switch (type) {
      case TetrominoType.I:
        return [
          [1, 1, 1, 1]
        ];
      case TetrominoType.O:
        return [
          [1, 1],
          [1, 1]
        ];
      case TetrominoType.T:
        return [
          [0, 1, 0],
          [1, 1, 1]
        ];
      case TetrominoType.S:
        return [
          [0, 1, 1],
          [1, 1, 0]
        ];
      case TetrominoType.Z:
        return [
          [1, 1, 0],
          [0, 1, 1]
        ];
      case TetrominoType.J:
        return [
          [1, 0, 0],
          [1, 1, 1]
        ];
      case TetrominoType.L:
        return [
          [0, 0, 1],
          [1, 1, 1]
        ];
    }
  }

  static Color _getDefaultColor(TetrominoType type) {
    switch (type) {
      case TetrominoType.I:
        return Colors.cyan;
      case TetrominoType.O:
        return Colors.yellow;
      case TetrominoType.T:
        return Colors.purple;
      case TetrominoType.S:
        return Colors.green;
      case TetrominoType.Z:
        return Colors.red;
      case TetrominoType.J:
        return Colors.blue;
      case TetrominoType.L:
        return Colors.orange;
    }
  }

  void rotateRight() {
    final List<List<int>> newShape = List.generate(
      shape[0].length,
      (i) => List.generate(shape.length, (j) => shape[shape.length - 1 - j][i]),
    );
    shape = newShape;
  }

  void moveLeft() => x--;
  void moveRight() => x++;
  void moveDown() => y++;
}
