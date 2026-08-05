import 'package:flutter/material.dart';

/// The colours.
///
/// A board of two greys, pieces in one colour because they are all yours, and
/// one warm colour for what can be taken.
class Palette {
  const Palette._();

  static const night = Color(0xFF16191C);
  static const board = Color(0xFF1F2429);
  static const light = Color(0xFF39434A);
  static const dark = Color(0xFF232930);

  static const piece = Color(0xFFE3E7EA);
  static const pieceEdge = Color(0xFF9AA4AC);
  static const picked = Color(0xFFE0A340);
  static const target = Color(0xFFD2685E);

  static const ink = Color(0xFFE7EAEC);
  static const inkDim = Color(0xFF8B959B);
  static const good = Color(0xFF7BAE6F);
  static const bad = Color(0xFFD2685E);
}
