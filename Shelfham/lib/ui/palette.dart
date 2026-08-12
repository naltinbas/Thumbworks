import 'package:flutter/material.dart';

/// Every colour in the game, and nowhere else.
class Palette {
  static const night = Color(0xFF1A1917);
  static const board = Color(0xFF252320);
  static const line = Color(0xFF393630);

  /// The shelf and the books, one coat a height.
  static const wood = Color(0xFF6E5A44);
  static const spines = [
    Color(0xFF5BB98C),
    Color(0xFF5B9BD5),
    Color(0xFFB07FD8),
    Color(0xFFE8B84B),
    Color(0xFFD87FA8),
  ];

  /// A step down, called out between two spines.
  static const step = Color(0xFFC96A4A);

  /// What the tools speak in.
  static const shown = Color(0xFF7EC8E3);
  static const good = Color(0xFF5BB98C);
  static const bad = Color(0xFFC96A4A);

  static const ink = Color(0xFFE8E2D6);
  static const inkDim = Color(0xFF9AA5AE);
}
