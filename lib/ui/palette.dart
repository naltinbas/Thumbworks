import 'dart:ui' show Color;

/// Every colour the game uses, in one place.
///
/// There is no art, so colour has to carry the whole answer to "is this word
/// real". The trace is blue while it is only letters, green the moment it is a
/// word worth taking, and amber when it is a word already found: three states
/// a player can learn without being told.
abstract final class Palette {
  static const backdrop = Color(0xFF0D1017);

  /// The slab the grid sits on, so the board reads as an object rather than as
  /// the whole screen.
  static const panel = Color(0xFF161B25);
  static const panelEdge = Color(0xFF262E3D);

  static const tile = Color(0xFF1F2734);
  static const tileEdge = Color(0xFF2E3849);

  static const ink = Color(0xFFE9EDF6);
  static const inkDim = Color(0xFF868FA3);

  /// A trace that is not a word yet. Nothing is wrong with it, so it is the
  /// colour of the game rather than a warning.
  static const trace = Color(0xFF5AA6FF);

  /// A trace that counts. Green because it means go, and because it has to be
  /// unmistakable at a glance with a thumb over half the board.
  static const word = Color(0xFF4FD69C);

  /// A word already found. Warm rather than red: it is not a mistake, it is
  /// just spent.
  static const stale = Color(0xFFE0B341);

  /// The clock in the last few seconds. The only red in the game, so it means
  /// one thing.
  static const alarm = Color(0xFFF06A5A);

  /// Laid over the board while the round is finished. Nearly solid: the
  /// letters are still there behind the score, but only just, because the
  /// score is what there is to read.
  static const scrim = Color(0xF70D1017);
}
