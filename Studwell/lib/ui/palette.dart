import 'package:flutter/material.dart';

/// The sham's colours: a flagged court at dusk, elbows in warm
/// stone, studs in brass, rust where the count bites.
class Palette {
  static const night = Color(0xFF15130F);
  static const board = Color(0xFF221E18);

  static const ink = Color(0xFFEDE7DC);
  static const inkDim = Color(0xFFA69E90);

  static const line = Color(0xFF3F382C);
  static const flag = Color(0xFF2E2922);
  static const flagRim = Color(0xFF4A4236);
  static const well = Color(0xFF0E0C09);
  static const wellRim = Color(0xFF6E6252);

  /// The elbows, four tints in turn so neighbours read apart.
  static const stones = [
    Color(0xFF9C7A54),
    Color(0xFF7D8A6C),
    Color(0xFF8A6E7C),
    Color(0xFF6E8598),
  ];
  static const seam = Color(0xFF15130F);

  static const stud = Color(0xFFD4A64A);
  static const studDim = Color(0xFF5C4C2C);

  static const picked = Color(0xFF64B5F6);
  static const shown = Color(0xFF64B5F6);
  static const good = Color(0xFF81C784);
  static const bad = Color(0xFFE57373);
}
