import 'package:flutter/material.dart';

/// Every colour in the game, and nowhere else.
class Palette {
  static const night = Color(0xFF171918);
  static const board = Color(0xFF212423);
  static const line = Color(0xFF333836);

  /// The cote and the players.
  static const cote = Color(0xFF243026);
  static const player = Color(0xFFB8B2A4);
  static const playerRim = Color(0xFF6E6A5E);

  /// The rounds, five coats worn in turn; given rounds dim.
  static const roundCoats = [
    Color(0xFF5BB98C),
    Color(0xFF5B9BD5),
    Color(0xFFB07FD8),
    Color(0xFFE8B84B),
    Color(0xFFD87FA8),
  ];

  /// What the tools speak in.
  static const shown = Color(0xFF7EC8E3);
  static const good = Color(0xFF5BB98C);
  static const bad = Color(0xFFC96A4A);

  static const ink = Color(0xFFE8E2D6);
  static const inkDim = Color(0xFF9AA5AE);
}
