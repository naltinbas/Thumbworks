import 'package:flutter/material.dart';

/// Every colour in the game, and nowhere else.
class Palette {
  static const night = Color(0xFF17181C);
  static const board = Color(0xFF212329);
  static const line = Color(0xFF32353E);

  /// The green and its posts.
  static const grass = Color(0xFF243024);
  static const post = Color(0xFF6E5A44);

  /// The lanterns.
  static const glow = Color(0xFFE8B84B);
  static const glowDim = Color(0xFF74622F);
  static const flame = Color(0xFFF7DFA0);

  /// The ropes, seven coats worn in turn.
  static const ropes = [
    Color(0xFF5BB98C),
    Color(0xFF5B9BD5),
    Color(0xFFB07FD8),
    Color(0xFFD88A5B),
    Color(0xFF57C4C9),
    Color(0xFFC9C95B),
    Color(0xFFD87FA8),
  ];

  /// A pair roped twice, called out.
  static const clash = Color(0xFFC96A4A);

  /// What the tools speak in.
  static const shown = Color(0xFF7EC8E3);
  static const good = Color(0xFF5BB98C);
  static const bad = Color(0xFFC96A4A);

  static const ink = Color(0xFFE8E2D6);
  static const inkDim = Color(0xFF9AA5AE);
}
