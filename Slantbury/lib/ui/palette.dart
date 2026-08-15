import 'package:flutter/material.dart';

/// The sham's colours: a bare frame in rose, the four pieces in blue,
/// teal, green and gold, the shared area in rust, the piece in hand
/// ringed in chalk.
class Palette {
  static const night = Color(0xFF17151A);
  static const board = Color(0xFF231F27);

  static const ink = Color(0xFFECEAE2);
  static const inkDim = Color(0xFF9A9C93);

  static const line = Color(0xFF3B3947);
  static const bare = Color(0xFFA34E4E);
  static const grid = Color(0xFF7A3A3A);
  static const frame = Color(0xFFB0A090);
  static const tray = Color(0xFF231F27);
  static const chalk = Color(0xFFECEAE2);
  static const outline = Color(0xFF17151A);
  static const gold = Color(0xFFD9A441);
  static const clash = Color(0xFFE57373);

  /// One colour to a piece: the two triangles, the two trapeziums.
  static const pieces = [
    Color(0xFF5B9BD5),
    Color(0xFF4DB6AC),
    Color(0xFF8BC34A),
    Color(0xFFD9A441),
  ];

  static const shown = Color(0xFF64B5F6);
  static const good = Color(0xFF81C784);
  static const bad = Color(0xFFE57373);
}
