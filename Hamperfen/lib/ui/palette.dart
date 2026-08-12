import 'package:flutter/material.dart';

/// Every colour in the game, and nowhere else.
class Palette {
  static const night = Color(0xFF181917);
  static const board = Color(0xFF232421);
  static const line = Color(0xFF373833);

  /// The baskets and the herbs.
  static const wicker = Color(0xFF8A6D4A);
  static const wickerDim = Color(0xFF5A4832);
  static const herbs = [
    Color(0xFF5BB98C),
    Color(0xFFE8B84B),
    Color(0xFFB07FD8),
    Color(0xFF5B9BD5),
  ];

  /// A taken basket's ring, and a swallowing called out.
  static const taken = Color(0xFFE8E2D6);
  static const swallow = Color(0xFFC96A4A);

  /// What the tools speak in.
  static const shown = Color(0xFF7EC8E3);
  static const good = Color(0xFF5BB98C);
  static const bad = Color(0xFFC96A4A);

  static const ink = Color(0xFFE8E2D6);
  static const inkDim = Color(0xFF9AA5AE);
}
