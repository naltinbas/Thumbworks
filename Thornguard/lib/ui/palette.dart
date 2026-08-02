import 'package:flutter/material.dart';

/// The colours.
///
/// A board game played at night: a dark slate board with the men carved out of
/// it in three tones. Rust for the raiders because there are three times as
/// many of them and they have to read as a crowd; bone for the guards; and the
/// king in gold, because he is the only piece on the board that matters and a
/// glance should say which one he is.
class Palette {
  const Palette._();

  /// Behind everything.
  static const night = Color(0xFF12161B);

  /// The board itself.
  static const board = Color(0xFF1C232B);

  /// The lines on it.
  static const rule = Color(0xFF2E3945);

  /// The corners and the throne, which are not ordinary squares.
  static const inlay = Color(0xFF39485A);

  static const raider = Color(0xFFB5533C);
  static const guard = Color(0xFFD9D3C5);
  static const king = Color(0xFFE8B84B);

  /// Text.
  static const ink = Color(0xFFE6E2DA);
  static const inkDim = Color(0xFF8A93A0);

  /// The square a man is standing on, once he has been picked up.
  static const picked = Color(0xFF3F5A52);

  /// Somewhere he could go.
  static const open = Color(0xFF52A98D);

  /// The move the other side just played, so a player who looked away knows
  /// what happened while they were not watching.
  static const last = Color(0xFF3A4E63);

  /// Getting somewhere.
  static const good = Color(0xFF52A98D);

  /// Laid over the board when the game is over.
  static const veil = Color(0xFF12161B);
}
