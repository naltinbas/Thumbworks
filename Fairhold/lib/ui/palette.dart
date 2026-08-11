import 'dart:ui';

/// A goods yard at the fair.
class Palette {
  const Palette._();

  /// The yard behind everything.
  static const yard = Color(0xFF1B1A16);

  /// Panels and cards: the tally shed boards.
  static const shed = Color(0xFF282622);

  /// Hairlines and quiet borders.
  static const line = Color(0xFF413D33);

  /// Borders that mean something.
  static const edge = Color(0xFF6B6352);

  /// Words.
  static const ink = Color(0xFFEFEDE2);

  /// Words standing back.
  static const inkDim = Color(0xFFA29C8B);

  /// The four paints: madder, weld, woad, lime.
  static const paints = [
    Color(0xFFC96A5A),
    Color(0xFFD9B84E),
    Color(0xFF6F9CC9),
    Color(0xFF8FBF7F),
  ];

  /// The two lines: north-south and east-west.
  static const northSouth = Color(0xFFE0B34E);
  static const eastWest = Color(0xFF8FB8D9);

  /// Crate wood, and the pointed-at chip.
  static const wood = Color(0xFF57503F);
  static const shown = Color(0xFFE0E4EA);

  /// A stack standing fair, and one gone wrong.
  static const good = Color(0xFF8FBF7F);
  static const bad = Color(0xFFCC7A66);
}
