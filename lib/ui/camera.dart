import 'dart:ui' show Offset, Size;

import '../sim/world.dart';
import 'playfield.dart';

/// Where the world sits on the screen.
///
/// The simulation works in metres and has no idea how big the glass is, so
/// this is the only place that decides. It is a value rather than an object
/// with state: the loop keeps the one number that moves, the height the view
/// has climbed to, and a camera is made from it and the size of the moment.
class Camera {
  const Camera({
    required this.size,
    required this.focusY,
    required this.pxPerMetre,
  });

  /// A camera that fills [size] and is looking at [focusY] metres up.
  factory Camera.forSize(Size size, double focusY) => Camera(
        size: size,
        focusY: focusY,
        pxPerMetre: size.width / viewWidthMetres,
      );

  /// How much of the world is across the screen, in metres.
  ///
  /// The playfield is fourteen metres wide and a run ends at its edges, so
  /// the scale is set by the width and not by the height: both walls have to
  /// be on screen with a little air outside them, on the narrowest phone
  /// anyone still owns. Whatever a taller screen has left over becomes sky to
  /// climb into, which is the direction the game is played in anyway.
  static const viewWidthMetres = 2 * Playfield.edgeX + 1.4;

  /// How far down the screen the height being followed is drawn.
  ///
  /// Below the middle, because the interesting part of a climb is above the
  /// craft. What is left underneath is enough to watch a fall play out: the
  /// run ends nine metres below the high point, and on a phone that is still
  /// on the glass.
  static const focusShare = 0.62;

  final Size size;

  /// The height in metres drawn at [focusLine].
  final double focusY;

  final double pxPerMetre;

  double get focusLine => size.height * focusShare;

  /// The same camera looking at a different height, which is how the
  /// background is drawn moving slower than the world.
  Camera lookingAt(double y) =>
      Camera(size: size, focusY: y, pxPerMetre: pxPerMetre);

  Offset toScreen(Vec at) => Offset(
        size.width / 2 + at.x * pxPerMetre,
        focusLine - (at.y - focusY) * pxPerMetre,
      );

  double px(double metres) => metres * pxPerMetre;

  /// The world height at the top and bottom edges of the screen, for deciding
  /// what is worth drawing at all.
  double get topY => focusY + focusLine / pxPerMetre;
  double get bottomY => focusY - (size.height - focusLine) / pxPerMetre;
}
