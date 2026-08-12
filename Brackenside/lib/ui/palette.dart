import 'package:flutter/material.dart';

/// Every colour in the game, and nowhere else.
class Palette {
  static const night = Color(0xFF181A17);
  static const board = Color(0xFF22251F);
  static const line = Color(0xFF34382E);

  /// The three plants.
  static const plants = <String, Color>{
    'A': Color(0xFF5BB98C),
    'B': Color(0xFFE8B84B),
    'C': Color(0xFFB07FD8),
  };

  /// What the plants are called out loud.
  static const plantNames = <String, String>{
    'A': 'bracken',
    'B': 'gorse',
    'C': 'heather',
  };

  /// A three-plant patch, ringed.
  static const patch = Color(0xFFE8E2D6);

  /// What the tools speak in.
  static const shown = Color(0xFF7EC8E3);
  static const good = Color(0xFF5BB98C);
  static const bad = Color(0xFFC96A4A);

  static const ink = Color(0xFFE8E2D6);
  static const inkDim = Color(0xFF9AA5AE);
}
