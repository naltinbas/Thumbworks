import 'package:flutter/material.dart';

/// Every colour in the game, and nowhere else.
class Palette {
  static const night = Color(0xFF17181B);
  static const board = Color(0xFF212328);
  static const line = Color(0xFF32353C);

  /// The four paints the boxes wear.
  static const paints = <String, Color>{
    'R': Color(0xFFC96A4A),
    'G': Color(0xFF5BB98C),
    'B': Color(0xFF5B9BD5),
    'W': Color(0xFFE8E2D6),
  };

  /// What the paints are called out loud.
  static const paintNames = <String, String>{
    'R': 'red',
    'G': 'green',
    'B': 'blue',
    'W': 'white',
  };

  /// A wall gone wrong, called out.
  static const clash = Color(0xFFE8B84B);

  /// What the tools speak in.
  static const shown = Color(0xFF7EC8E3);
  static const good = Color(0xFF5BB98C);
  static const bad = Color(0xFFC96A4A);

  static const ink = Color(0xFFE8E2D6);
  static const inkDim = Color(0xFF9AA5AE);
}
