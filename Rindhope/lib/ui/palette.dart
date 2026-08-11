import 'dart:ui';

/// A larder shelf, cheese and shadow.
class Palette {
  const Palette._();

  /// The larder behind everything.
  static const larder = Color(0xFF1D1B16);

  /// Panels and cards: the shelf boards.
  static const shelf = Color(0xFF2A2620);

  /// Hairlines and quiet borders.
  static const line = Color(0xFF423B2E);

  /// Borders that mean something.
  static const edge = Color(0xFF6C5F47);

  /// Words.
  static const ink = Color(0xFFEFE9D8);

  /// Words standing back.
  static const inkDim = Color(0xFFA09378);

  /// The cheese, its rind, and the holes in it.
  static const cheese = Color(0xFFE8C86A);
  static const rind = Color(0xFFB3923F);
  static const hole = Color(0xFFD1AF52);

  /// The mouldy crumb.
  static const mould = Color(0xFF7A8A5A);
  static const mouldDark = Color(0xFF55613E);

  /// The grey mouse, drawn at its last bite.
  static const mouse = Color(0xFF9A9AA2);

  /// The mirror line on squares, when the game is asked why.
  static const mirror = Color(0xFFE0B34E);

  /// The pointed-at crumb when the game is asked to show.
  static const shown = Color(0xFF8FB8D9);

  /// A block won, and one lost.
  static const good = Color(0xFF8FBF7F);
  static const bad = Color(0xFFCC7A66);
}
