import 'package:flutter/material.dart';

/// The colours.
///
/// A parish map on a table. The hamlets are little dark squares, the paths that
/// could be cut are faint, and the ones that have been cut are the colour of
/// bare chalk trodden through grass.
class Palette {
  const Palette._();

  static const night = Color(0xFF0D1210);
  static const verge = Color(0xFF171E1A);
  static const line = Color(0xFF232C26);
  static const edge = Color(0xFF394439);

  static const could = Color(0xFF35403A);
  static const trod = Color(0xFFCFC29A);
  static const place = Color(0xFF6D7A6E);
  static const joined = Color(0xFFA9BDA6);

  static const thisSide = Color(0xFF7FB1C9);
  static const thatSide = Color(0xFFD09A62);
  static const loop = Color(0xFFD9736A);

  static const ink = Color(0xFFEAEEE9);
  static const inkDim = Color(0xFF879088);
  static const good = Color(0xFF8CBB6D);
  static const bad = Color(0xFFD9736A);
}
