import 'package:flutter/material.dart';

/// The colours.
///
/// A wooden board with hollows drilled in it and pegs standing in them. One
/// warm colour for a peg, a second for the peg part way through a move, and a
/// dark ring for a hollow with nothing in it.
class Palette {
  const Palette._();

  static const night = Color(0xFF171412);
  static const wood = Color(0xFF241E1A);
  static const grain = Color(0xFF2F2823);
  static const edge = Color(0xFF443A33);

  static const peg = Color(0xFFD9A05B);
  static const pegEdge = Color(0xFFE9C08C);
  static const moving = Color(0xFF7FB86D);
  static const hollow = Color(0xFF120F0E);

  static const ink = Color(0xFFEDE7E0);
  static const inkDim = Color(0xFF988C82);
  static const good = Color(0xFF7FB86D);
  static const bad = Color(0xFFD4736B);
}
