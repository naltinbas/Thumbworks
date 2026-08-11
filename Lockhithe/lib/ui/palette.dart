import 'dart:ui';

/// A quayside store at first light.
class Palette {
  const Palette._();

  /// The store behind everything.
  static const quay = Color(0xFF161B1E);

  /// Panels and cards: the wharf boards.
  static const wharf = Color(0xFF232B2F);

  /// Hairlines and quiet borders.
  static const line = Color(0xFF39444A);

  /// Borders that mean something.
  static const edge = Color(0xFF5C6E77);

  /// Words.
  static const ink = Color(0xFFE8ECEA);

  /// Words standing back.
  static const inkDim = Color(0xFF93A0A0);

  /// A locker door, its rim, and the inside once opened.
  static const door = Color(0xFF4A5A63);
  static const rim = Color(0xFF31404A);
  static const inside = Color(0xFF1E2529);

  /// A chit, and the player's own chit.
  static const chit = Color(0xFFD9C99A);
  static const own = Color(0xFF8FBF7F);

  /// The player's colour, and the crew's.
  static const you = Color(0xFF63B0E3);
  static const crew = Color(0xFFC98F4E);

  /// The ropes of the loops, four to cycle through.
  static const ropes = [
    Color(0xFFD9BE55),
    Color(0xFF8FB8D9),
    Color(0xFFC97FA8),
    Color(0xFF8FBF7F),
  ];

  /// The pointed-at locker when the game is asked to show.
  static const shown = Color(0xFF8FB8D9);

  /// A crew through, and one sunk.
  static const good = Color(0xFF8FBF7F);
  static const bad = Color(0xFFCC7A66);
}
