import 'package:flutter/material.dart';

/// Every colour in the game, and nowhere else.
class Palette {
  static const night = Color(0xFF191817);
  static const board = Color(0xFF242321);
  static const line = Color(0xFF383632);

  /// The three paints.
  static const paints = [
    Color(0xFFC96A4A),
    Color(0xFF5B9BD5),
    Color(0xFF5BB98C),
  ];

  /// What the paints are called out loud.
  static const paintNames = ['madder', 'indigo', 'moss'];

  /// A bad sum's stones, ringed.
  static const badSum = Color(0xFFE8B84B);

  /// What the tools speak in.
  static const shown = Color(0xFF7EC8E3);
  static const good = Color(0xFF5BB98C);
  static const bad = Color(0xFFC96A4A);

  static const ink = Color(0xFFE8E2D6);
  static const inkDim = Color(0xFF9AA5AE);
}
