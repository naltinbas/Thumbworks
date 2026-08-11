import 'dart:ui';

/// A ploughed strip at seed time.
class Palette {
  const Palette._();

  /// The field behind everything.
  static const field = Color(0xFF1B1914);

  /// Panels and cards: the barn boards.
  static const barnwood = Color(0xFF292319);

  /// Hairlines and quiet borders.
  static const line = Color(0xFF423A2A);

  /// Borders that mean something.
  static const edge = Color(0xFF6E6146);

  /// Words.
  static const ink = Color(0xFFF0EAD9);

  /// Words standing back.
  static const inkDim = Color(0xFFA39678);

  /// A furrow's trough, and the tilth around it.
  static const trough = Color(0xFF241F16);
  static const tilth = Color(0xFF33291B);

  /// A seed, and its light side.
  static const seed = Color(0xFFD9B84E);
  static const seedLight = Color(0xFFE8CE7A);

  /// The barn, and its roof.
  static const barn = Color(0xFF8A4A3E);
  static const roof = Color(0xFF5C3129);

  /// A sowable furrow's rim, a trapped one's, and the pointed-at one.
  static const sowable = Color(0xFF8FBF7F);
  static const trapped = Color(0xFFCC7A66);
  static const shown = Color(0xFF8FB8D9);

  /// A tilth home, and one dead.
  static const good = Color(0xFF8FBF7F);
  static const bad = Color(0xFFCC7A66);
}
