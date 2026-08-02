import 'package:flutter/material.dart';

/// The colours.
///
/// A workbench under one lamp: dark wood, brass, and eight peg colours that
/// have to be told apart at a glance and at a quarter of an inch.
class Palette {
  const Palette._();

  static const night = Color(0xFF15181B);
  static const bench = Color(0xFF1E2429);
  static const groove = Color(0xFF2B343A);

  static const brass = Color(0xFFD9A441);
  static const ink = Color(0xFFE7EAEC);
  static const inkDim = Color(0xFF8B959B);
  static const good = Color(0xFF6FB07A);
  static const bad = Color(0xFFD3574C);

  /// A peg that is right where it is, and one that is the right colour in the
  /// wrong place.
  static const black = Color(0xFFE7EAEC);
  static const white = Color(0xFF6D7A83);

  /// The eight peg colours.
  ///
  /// Eight hues that are also eight brightnesses, and each one carries a shape
  /// of its own besides. A code game that can only be played by people who see
  /// colour the way whoever made it does is a code game half the world cannot
  /// play.
  static const pegs = <Color>[
    Color(0xFFD9534F),
    Color(0xFFE0A33F),
    Color(0xFF6FAF63),
    Color(0xFF4FA8A0),
    Color(0xFF5B8FD0),
    Color(0xFF9A7BD0),
    Color(0xFFD06FA8),
    Color(0xFF95A3AE),
  ];

  static Color forPeg(int colour) => pegs[colour % pegs.length];
}
