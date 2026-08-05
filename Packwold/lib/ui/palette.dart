import 'package:flutter/material.dart';

/// The colours.
///
/// Bare chalk ground with painted wooden shapes on it. Each of the twelve
/// pieces keeps its colour everywhere it appears, in every puzzle, so the T
/// is the same green in the tray as it is on the box and as it was two
/// puzzles ago. The letter is painted on it as well: twelve colours is more
/// than anybody should have to tell apart, and the letters are the names
/// these shapes have had since 1953.
class Palette {
  const Palette._();

  static const night = Color(0xFF14161A);
  static const chalk = Color(0xFF232830);
  static const furrow = Color(0xFF2E353F);
  static const edge = Color(0xFF3C4552);

  static const ink = Color(0xFFE8EBEF);
  static const inkDim = Color(0xFF8B94A1);
  static const good = Color(0xFF7FB86D);
  static const bad = Color(0xFFD4736B);

  /// One for each pentomino, in the order the letters go: F I L N P T U V W
  /// X Y Z.
  static const paint = <Color>[
    Color(0xFFE0705A), // F  rust
    Color(0xFF5FA8D3), // I  sky
    Color(0xFFE4B23C), // L  ochre
    Color(0xFF9C8CE0), // N  violet
    Color(0xFF4FBCA6), // P  teal
    Color(0xFF7DBE68), // T  moss
    Color(0xFFC86FA8), // U  heather
    Color(0xFFD98A45), // V  copper
    Color(0xFF6FA9E0), // W  cornflower
    Color(0xFFCB6C6C), // X  brick
    Color(0xFFB6C25E), // Y  lichen
    Color(0xFF8E9BB5), // Z  slate blue
  ];

  static Color paintFor(int piece) => paint[piece % paint.length];
}
