import 'dart:ui' show Color;

/// Every colour the game draws with, in one place.
///
/// There is no art to load, so colour has to carry the reading of the screen.
/// The scheme is one idea: the world is cold and the player is warm. Wells,
/// walls and altitude marks are cyan through slate; the craft, its trail and
/// the flash when it lets go are the only gold on screen. A glance says which
/// moving thing is you.
abstract final class Palette {
  /// Behind everything. Darker at the top, so climbing reads as leaving
  /// something behind rather than sliding along.
  static const skyTop = Color(0xFF04060C);
  static const skyBottom = Color(0xFF0D1424);

  /// Specks in the background, drawn at a fraction of the camera's speed so
  /// the climb has something to be measured against.
  static const dust = Color(0xFFB9D4FF);

  /// Altitude marks and their numbers.
  static const rung = Color(0xFF1E2740);
  static const rungInk = Color(0xFF5A648C);

  /// The sides of the playfield, which end a run.
  static const wall = Color(0xFFE05A78);

  /// A well nobody has used yet.
  static const well = Color(0xFF4FD8E8);

  /// The same well once the craft has been round it. No glow and no colour
  /// left: a used well still holds, it is just not worth anything.
  static const wellUsed = Color(0xFF3B4661);

  /// The well currently holding the craft.
  static const wellHeld = Color(0xFFCFF7FF);

  /// The solid middle of a well, and the ring that says it is solid.
  static const wellCore = Color(0xFF060E16);
  static const wellDanger = Color(0xFFFF6B8A);

  /// The craft, its trail, and the burst when it lets go.
  static const craft = Color(0xFFFFD36E);
  static const craftHot = Color(0xFFFFF6DF);

  /// Words drawn into the world rather than into the interface.
  static const ink = Color(0xFFE9EDF7);
}
