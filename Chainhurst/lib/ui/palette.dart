import 'package:flutter/material.dart';

/// Every colour in the game, and nowhere else.
class Palette {
  static const night = Color(0xFF161A17);
  static const board = Color(0xFF20261F);
  static const line = Color(0xFF303A2E);

  /// The field and its crossings.
  static const grass = Color(0xFF2A3627);
  static const cross = Color(0xFF4A5A46);

  /// The stones.
  static const stone = Color(0xFFB8B2A4);
  static const stoneRim = Color(0xFF6E6A5E);

  /// The chains: bare gold, laden moss.
  static const bare = Color(0xFFE8B84B);
  static const laden = Color(0xFF5BB98C);

  /// What the tools speak in.
  static const shown = Color(0xFF7EC8E3);
  static const good = Color(0xFF5BB98C);
  static const bad = Color(0xFFC96A4A);

  static const ink = Color(0xFFE8E2D6);
  static const inkDim = Color(0xFF9AA5AE);
}
