import 'package:flutter/material.dart';

/// Every colour in the game, and nowhere else.
class Palette {
  static const night = Color(0xFF191817);
  static const board = Color(0xFF242220);
  static const line = Color(0xFF383430);

  /// The cloth and the two threads.
  static const cloth = Color(0xFF2C2925);
  static const madder = Color(0xFFC96A4A);
  static const indigo = Color(0xFF5B7BD5);

  /// What the threads are called out loud.
  static const threadNames = <String, String>{
    'R': 'madder',
    'B': 'indigo',
  };

  static Color threadOf(String thread) =>
      thread == 'R' ? madder : indigo;

  /// A ladder, called out.
  static const ladder = Color(0xFFE8B84B);

  /// What the tools speak in.
  static const shown = Color(0xFF7EC8E3);
  static const good = Color(0xFF5BB98C);
  static const bad = Color(0xFFC96A4A);

  static const ink = Color(0xFFE8E2D6);
  static const inkDim = Color(0xFF9AA5AE);
}
