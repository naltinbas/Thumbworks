import 'dart:ui';

/// A nursery floor at golden hour.
class Palette {
  const Palette._();

  /// The floor behind everything.
  static const floor = Color(0xFF201B14);

  /// Panels and cards: the toybox boards.
  static const toybox = Color(0xFF2D261C);

  /// Hairlines and quiet borders.
  static const line = Color(0xFF463C2C);

  /// Borders that mean something.
  static const edge = Color(0xFF6F5F45);

  /// Words.
  static const ink = Color(0xFFF0E9D8);

  /// Words standing back.
  static const inkDim = Color(0xFFA4967C);

  /// The shelf the blocks sit on, and an empty seat.
  static const shelf = Color(0xFF4A3E2B);
  static const seat = Color(0xFF2A241B);

  /// The blocks, one colour to a number, one to eight.
  static const blocks = [
    Color(0xFFC96A5A),
    Color(0xFFD99A4E),
    Color(0xFFC9B84F),
    Color(0xFF8FBF7F),
    Color(0xFF6FAE9C),
    Color(0xFF6F9CC9),
    Color(0xFF9C86C9),
    Color(0xFFC97FA8),
  ];

  /// The pointed-at seat when the game is asked to show.
  static const shown = Color(0xFF8FB8D9);

  /// A shelf set, and one stranded.
  static const good = Color(0xFF8FBF7F);
  static const bad = Color(0xFFCC7A66);
}
