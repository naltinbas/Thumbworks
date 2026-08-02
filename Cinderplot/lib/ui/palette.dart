import 'package:flutter/material.dart';

/// The colours.
///
/// Ground that has not been turned over, ground that has, and one warm colour
/// for the things that matter — the flags, and the mine that ends it.
class Palette {
  const Palette._();

  static const night = Color(0xFF16191C);
  static const plot = Color(0xFF1E2226);

  /// A square nobody has opened.
  static const shut = Color(0xFF3A4249);
  static const shutEdge = Color(0xFF464F58);

  /// A square that has been opened.
  static const turned = Color(0xFF23282D);
  static const furrow = Color(0xFF2C3238);

  static const ember = Color(0xFFE8853A);
  static const mine = Color(0xFFD65246);
  static const proved = Color(0xFF7FBF6A);

  static const ink = Color(0xFFE7EAEC);
  static const inkDim = Color(0xFF8C959C);

  /// The number on a square, by what it says. Colouring them is not
  /// decoration: at a glance a board of numbers is a board of colours, and
  /// the pair a rule wants is a pair you can see without reading.
  static const numbers = <Color>[
    Color(0xFF000000), // never drawn — a nought is drawn as nothing at all
    Color(0xFF6FA8DC),
    Color(0xFF83C77A),
    Color(0xFFE8776E),
    Color(0xFFB39CE0),
    Color(0xFFE8B04B),
    Color(0xFF6FC7C0),
    Color(0xFFE49AC4),
    Color(0xFFA8B2BA),
  ];

  static Color forNumber(int count) => numbers[count.clamp(1, 8)];
}
