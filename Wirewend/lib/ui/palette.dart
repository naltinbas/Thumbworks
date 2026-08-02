import 'dart:ui' show Color;

/// Every colour the board uses, in one place.
///
/// There is no art to load, so colour and shape carry the whole game. The
/// scheme is one idea: current is cold, light is warm, and anything the
/// current has not reached is slate. That way a glance at the board says
/// which parts are live without reading any wire.
abstract final class Palette {
  /// Behind everything, for a screen to fill with.
  static const backdrop = Color(0xFF0B0D14);

  /// The panel the grid sits on, so the board reads as an object rather than
  /// as the whole screen.
  static const panel = Color(0xFF131722);
  static const panelEdge = Color(0xFF232A3B);

  /// The panel edge once every lamp is lit.
  static const solvedEdge = Color(0xFFF6C453);

  /// A cell with wire in it, dark and slightly lighter once it is live.
  static const tile = Color(0xFF1B2130);
  static const tileLive = Color(0xFF1F2A3D);

  /// A cell with no wire at all. Darker than a tile so gaps read as holes in
  /// the board rather than as pieces waiting to be turned.
  static const hole = Color(0xFF10141F);

  static const wireIdle = Color(0xFF3A4258);
  static const wireLive = Color(0xFF5BD6EA);

  /// The source, which is always live, so it only needs the one pair.
  static const sourceBody = Color(0xFF37B7CE);
  static const sourceCore = Color(0xFFEAFDFF);

  /// Words. The dim one is for anything that is not the thing being read at
  /// that moment, which on a board screen is nearly all of it.
  static const ink = Color(0xFFE9EDF7);
  static const inkDim = Color(0xFF8A93AA);

  /// The one warm colour outside the board. It is the gold of a lit lamp on
  /// purpose: the button that follows a solved level is the same event as the
  /// board lighting up, so it should not be a different colour.
  static const accent = Color(0xFFF6C453);
  static const accentInk = Color(0xFF1A1305);

  static const lampIdle = Color(0xFF242B3C);
  static const lampLit = Color(0xFFFFC65C);
  static const lampRimIdle = Color(0xFF3A4258);
  static const lampRimLit = Color(0xFFFFE7AE);
}
