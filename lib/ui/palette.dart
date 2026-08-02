import 'package:flutter/material.dart';

/// The colours.
///
/// A back room with a green baize table in it: dark wood, one lamp, and the
/// two colours that matter — what you have and what they have.
class Palette {
  const Palette._();

  static const night = Color(0xFF14171A);
  static const felt = Color(0xFF1D262A);
  static const rail = Color(0xFF2A353A);

  static const yours = Color(0xFFE0A93F);
  static const theirs = Color(0xFF7FA5C4);

  static const die = Color(0xFFEDE8DC);
  static const pip = Color(0xFF20262A);
  static const bad = Color(0xFFD3574C);
  static const good = Color(0xFF6FB07A);

  static const ink = Color(0xFFE7EAEC);
  static const inkDim = Color(0xFF8B959B);

  static Color forWho(bool mine) => mine ? yours : theirs;
}
