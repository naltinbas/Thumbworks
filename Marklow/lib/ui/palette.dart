import 'package:flutter/material.dart';

/// Every colour in the game, and nowhere else.
class Palette {
  static const night = Color(0xFF171819);
  static const board = Color(0xFF212224);
  static const line = Color(0xFF343538);

  /// The posts and the lines between them.
  static const post = Color(0xFFB8B2A4);
  static const postRim = Color(0xFF6E6A5E);
  static const wire = Color(0xFF5B9BD5);

  /// The marks and the gaps.
  static const mark = Color(0xFFE8E2D6);
  static const gap = Color(0xFF5BB98C);

  /// Clashing marks and repeated gaps, called out.
  static const clash = Color(0xFFC96A4A);

  /// What the tools speak in.
  static const shown = Color(0xFF7EC8E3);
  static const good = Color(0xFF5BB98C);
  static const bad = Color(0xFFC96A4A);

  static const ink = Color(0xFFE8E2D6);
  static const inkDim = Color(0xFF9AA5AE);
}
