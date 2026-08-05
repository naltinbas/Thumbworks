import 'package:flutter/material.dart';

/// The colours.
///
/// A dark peat board with wool laid across it. The eight thread colours are
/// as far apart in hue as eight can be, but they are never the only thing
/// telling one thread from another — the ends carry shapes as well, and the
/// shapes are what a player matches. See [Knots].
class Palette {
  const Palette._();

  static const night = Color(0xFF14181A);
  static const peat = Color(0xFF1B2124);
  static const furrow = Color(0xFF262E32);
  static const edge = Color(0xFF39434A);

  static const ink = Color(0xFFE7EBEA);
  static const inkDim = Color(0xFF8A9490);
  static const good = Color(0xFF7DBE68);
  static const bad = Color(0xFFD1706A);

  /// One for each thread, in the order the letters go.
  static const wool = <Color>[
    Color(0xFFC86FA8), // heather
    Color(0xFFE4B23C), // gorse
    Color(0xFF5FA8D3), // sky
    Color(0xFF7DBE68), // moss
    Color(0xFFE0705A), // rowan
    Color(0xFF9C8CE0), // flax
    Color(0xFFD98A45), // copper
    Color(0xFF4FBCA6), // teal
  ];

  static Color woolFor(int thread) => wool[thread % wool.length];
}
