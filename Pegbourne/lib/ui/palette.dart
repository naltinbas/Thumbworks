import 'package:flutter/material.dart';

/// The colours of the game: a parlour table, pegs in painted wood.
class Palette {
  static const table = Color(0xFF16131A);
  static const panel = Color(0xFF211D28);
  static const line = Color(0xFF3B3446);
  static const edge = Color(0xFF574D66);
  static const ink = Color(0xFFEFEBE2);
  static const inkDim = Color(0xFFA39BAE);

  static const slot = Color(0xFF241F2C);
  static const slotRim = Color(0xFF443C52);

  /// The four peg colours: red, green, blue, yellow.
  static const pegColours = [
    Color(0xFFC45A4A),
    Color(0xFF6FA05E),
    Color(0xFF5A87B8),
    Color(0xFFD9B04E),
  ];

  static const black = Color(0xFF15110C);
  static const white = Color(0xFFE8E2D4);

  static const shown = Color(0xFF64B6F0);
  static const kept = Color(0xFF8FBD8F);
  static const brokenRow = Color(0xFFD9705C);
  static const other = Color(0xFFC9A25B);

  static const good = Color(0xFF8FBD8F);
  static const bad = Color(0xFFD9705C);
}
