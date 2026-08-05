import 'package:flutter/material.dart';

/// The colours.
///
/// Grey stone on wet moorland, one lichen colour for the numbers the game
/// will show you, and two for the only two things that ever happen.
class Palette {
  const Palette._();

  static const night = Color(0xFF14181A);
  static const moor = Color(0xFF1D2427);
  static const ledge = Color(0xFF2A3336);

  static const stone = Color(0xFF9AA6AA);
  static const stoneEdge = Color(0xFF6E797D);
  static const going = Color(0xFFD8A657);

  static const lichen = Color(0xFF8FBF7F);
  static const good = Color(0xFF8FBF7F);
  static const bad = Color(0xFFD07A6A);

  static const ink = Color(0xFFE8EBEC);
  static const inkDim = Color(0xFF8D989C);

  static Color forWho(bool mine) => mine ? going : stone;
}
