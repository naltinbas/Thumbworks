import 'package:flutter/material.dart';

/// The colours.
///
/// A map by lamplight. The places are pale marks on dark ground, the road
/// already driven is warm, and the only other colour is the one the game
/// draws when a round comes home longer than it had to be.
class Palette {
  const Palette._();

  static const night = Color(0xFF14130F);
  static const ground = Color(0xFF1E1C17);
  static const hedge = Color(0xFF2A2721);
  static const edge = Color(0xFF443F34);

  static const stop = Color(0xFF9AA08C);
  static const yard = Color(0xFF7FB86D);
  static const road = Color(0xFFE0A05F);
  static const cart = Color(0xFFF3CE9B);

  static const ink = Color(0xFFEDEAE2);
  static const inkDim = Color(0xFF938E82);
  static const good = Color(0xFF7FB86D);
  static const bad = Color(0xFFD4796B);
}
