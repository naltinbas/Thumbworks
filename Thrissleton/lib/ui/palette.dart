import 'package:flutter/material.dart';

/// The leton's colours: river stones on dark turf, a wash of
/// green for every third, and the three remainders told apart
/// by the ink they wear.
class Palette {
  static const night = Color(0xFF131611);
  static const board = Color(0xFF1F241C);

  static const ink = Color(0xFFECEDE2);
  static const inkDim = Color(0xFFA0A691);

  static const line = Color(0xFF3C4433);
  static const stone = Color(0xFF9BA48E);
  static const stoneDark = Color(0xFF6E7562);
  static const held = Color(0xFF8A6B42);

  /// The remainders' inks: nought, one and two of threes.
  static const nought = Color(0xFFE0BE52);
  static const one = Color(0xFF2A2E24);
  static const two = Color(0xFF3D5470);

  static const third = Color(0x2E81C784);
  static const thirdRim = Color(0x8081C784);

  static const shown = Color(0xFF64B5F6);
  static const good = Color(0xFF81C784);
  static const bad = Color(0xFFE57373);
}
