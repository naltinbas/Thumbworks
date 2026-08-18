import 'package:flutter/material.dart';

/// A rope walk by lamplight: dark boards, and the three dyes a rope yard
/// kept, madder red, woad blue and weld yellow.
class Palette {
  static const night = Color(0xFF12110F);
  static const board = Color(0xFF1C1A17);

  static const ink = Color(0xFFE9E4D7);
  static const inkDim = Color(0xFF938C7B);

  static const line = Color(0xFF3A362D);

  static const madder = Color(0xFFC05A45);
  static const woad = Color(0xFF5E8FBF);
  static const weld = Color(0xFFD3B24C);

  /// The three dyes, in the order a tap steps through them.
  static const ropes = [madder, woad, weld];

  static const names = ['madder', 'woad', 'weld'];

  static const shown = Color(0xFF6BA5D4);
  static const good = Color(0xFF8AAE6D);
  static const bad = Color(0xFFC05A45);
}
