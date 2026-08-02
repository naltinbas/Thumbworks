import 'package:flutter/material.dart';

/// The colours.
///
/// A green table, because a card game played on anything else looks like a
/// card game somebody redesigned. Everything is one or two steps from that:
/// darker green for an empty slot, near-white for a card, and the two card
/// colours as close to printed ink as a screen gets.
class Palette {
  const Palette._();

  static const felt = Color(0xFF15413A);
  static const feltDark = Color(0xFF0F332D);

  /// An empty cell, home or column.
  static const slot = Color(0xFF11362F);
  static const slotEdge = Color(0xFF2B5C52);

  static const card = Color(0xFFF6F3EC);
  static const cardEdge = Color(0xFFCFC9BC);
  static const shadow = Color(0x33000000);

  static const black = Color(0xFF1E2228);
  static const red = Color(0xFFC03A2E);

  /// Round whatever the hint is pointing at.
  static const pointed = Color(0xFFE9B44C);

  static const ink = Color(0xFFEDF2EE);
  static const inkDim = Color(0xFF8FAAA1);
  static const good = Color(0xFFE9B44C);
}
