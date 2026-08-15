import 'package:flutter/material.dart';

/// The sham's colours: a flagged yard in grey stone, bricks in
/// terracotta, the drain in iron, the three colours of the slant faint
/// on the hopeless yard, green where the yard is paved and rust where
/// it is stuck.
class Palette {
  static const night = Color(0xFF17151A);
  static const board = Color(0xFF231F27);

  static const ink = Color(0xFFECEAE2);
  static const inkDim = Color(0xFF9A9C93);

  static const line = Color(0xFF3B3947);
  static const yardEdge = Color(0xFF3A3630);
  static const flag = Color(0xFF6E6A62);
  static const grout = Color(0xFF4A463F);
  static const drain = Color(0xFF26242A);
  static const iron = Color(0xFF7A7F88);
  static const brick = Color(0xFFB8623A);
  static const brickLight = Color(0xFFD48A5E);
  static const brickDark = Color(0xFF7A3D22);

  /// The three colours of a slant, worn faint by the flags.
  static const slant = [
    Color(0xFFD9A441),
    Color(0xFF64B5F6),
    Color(0xFF81C784),
  ];

  static const shown = Color(0xFF64B5F6);
  static const good = Color(0xFF81C784);
  static const bad = Color(0xFFE57373);
}
