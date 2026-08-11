import 'dart:ui';

/// A village green on fixture day.
class Palette {
  const Palette._();

  /// Beyond the green.
  static const evening = Color(0xFF191C18);

  /// Panels and cards: the pavilion boards.
  static const pavilion = Color(0xFF262A24);

  /// Hairlines and quiet borders.
  static const line = Color(0xFF3B4238);

  /// Borders that mean something.
  static const edge = Color(0xFF5F6B58);

  /// Words.
  static const ink = Color(0xFFECEEE6);

  /// Words standing back.
  static const inkDim = Color(0xFF9AA392);

  /// The sides' badges, ten colours round the wheel.
  static const badges = [
    Color(0xFFC96A5A),
    Color(0xFFD99A4E),
    Color(0xFFC9B84F),
    Color(0xFF8FBF7F),
    Color(0xFF6FAE9C),
    Color(0xFF6F9CC9),
    Color(0xFF9C86C9),
    Color(0xFFC97FA8),
    Color(0xFF8A8474),
    Color(0xFFB5854A),
  ];

  /// This round's matches, and the ghost wheel.
  static const match = Color(0xFFE3DFD0);
  static const ghost = Color(0xFFD9BE55);

  /// The picked side, and the pointed-at pairing.
  static const picked = Color(0xFFE0E4EA);
  static const shown = Color(0xFF8FB8D9);

  /// A card written, and one stranded.
  static const good = Color(0xFF8FBF7F);
  static const bad = Color(0xFFCC7A66);
}
