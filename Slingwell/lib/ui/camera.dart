import 'dart:math' as math;
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
  ///
  /// The scale comes off the width, unless the screen is wide enough for its
  /// height that doing so would push the bottom of the playfield past the
  /// bottom of the glass. A tablet is: fourteen metres across 768 points is
  /// fifty pixels a metre, and the fall that ends a run is then longer than
  /// what is left under the focus line, so the craft would vanish off the
  /// bottom a moment before the game said the run was over. On a screen like
  /// that the height decides instead, and the leftover width becomes sky.
  factory Camera.forSize(Size size, double focusY) => Camera(
        size: size,
        focusY: focusY,
        pxPerMetre: math.min(
          size.width / viewWidthMetres,
          size.height * (1 - focusShare) / viewBelowMetres,
        ),
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
  /// craft. What is left underneath is enough to watch a fall play out.
  static const focusShare = 0.62;

  /// How much world has to be drawable below the height being followed.
  ///
  /// The run ends nine metres below the high point, but the craft is drawn
  /// lower than that before it does: the step it dies on carries it a little
  /// past the line, and the nose of the craft is drawn ahead of where the
  /// simulation says it is. Playing three thousand seeds two ways puts the
  /// lowest pixel ever drawn 9.6 metres under the focus, so this is that with
  /// room to spare. screen_fit_test.dart is what keeps it honest.
  static const viewBelowMetres = 10.5;

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
