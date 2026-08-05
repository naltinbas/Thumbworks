import 'package:flutter/material.dart';

/// The colours.
///
/// A dark hillside with lamps on it. One warm colour for a lamp that is lit,
/// and the same colour dimmed for one that has gone out — because a lamp that
/// is out is still a lamp.
class Palette {
  const Palette._();

  static const night = Color(0xFF15171B);
  static const hill = Color(0xFF1E2228);
  static const socket = Color(0xFF2A2F37);

  static const lit = Color(0xFFEBBA5A);
  static const litEdge = Color(0xFFF2D18F);
  static const out = Color(0xFF343A44);
  static const outEdge = Color(0xFF3F4650);

  static const ink = Color(0xFFE8EAED);
  static const inkDim = Color(0xFF8C939C);
  static const good = Color(0xFF7FB073);
  static const bad = Color(0xFFD1706A);
}
