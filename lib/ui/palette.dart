import 'package:flutter/material.dart';

/// The colours.
///
/// A slate. Everything is chalk on dark grey except the two things that
/// matter — the ball and the ring — because on a board covered in white lines
/// those are the only things a player needs to find at a glance.
class Palette {
  const Palette._();

  static const slate = Color(0xFF232A2E);
  static const slateDeep = Color(0xFF1A2024);

  /// What is already drawn on the board and cannot be rubbed out.
  static const fixed = Color(0xFF8E9AA2);

  /// What the player has drawn.
  static const chalk = Color(0xFFF2EFE6);

  /// Chalk being drawn right now.
  static const wet = Color(0xFFFFFFFF);

  static const ball = Color(0xFFE8B04B);
  static const ring = Color(0xFF5FC9A0);
  static const spike = Color(0xFFDD6472);

  static const ink = Color(0xFFECEFF1);
  static const inkDim = Color(0xFF8E9AA2);
}
