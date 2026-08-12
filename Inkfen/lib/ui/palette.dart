import 'package:flutter/material.dart';

/// The fen's colours: three inks on a dusk green, rust where
/// two strings clash at a post.
class Palette {
  static const night = Color(0xFF131511);
  static const board = Color(0xFF1E231B);

  static const ink = Color(0xFFECEDE2);
  static const inkDim = Color(0xFFA0A691);

  static const line = Color(0xFF3B4232);
  static const post = Color(0xFF8A7A5C);
  static const bare = Color(0xFF4A5340);

  /// The pot: madder, indigo and gold.
  static const madder = Color(0xFFC4614C);
  static const indigo = Color(0xFF5E7A99);
  static const gold = Color(0xFFE0BE52);

  static const clash = Color(0xFFE57373);

  static const shown = Color(0xFF64B5F6);
  static const good = Color(0xFF81C784);
  static const bad = Color(0xFFE57373);

  static Color ofInk(int dipped) => switch (dipped) {
        1 => madder,
        2 => indigo,
        3 => gold,
        _ => bare,
      };
}
