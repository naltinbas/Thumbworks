import 'dart:math' as math;
import 'dart:ui';

import '../game/board.dart';

/// Where the squares of a board sit in the space the view was given.
///
/// The painter, the gesture and the tests all have to agree on this, so it is
/// worked out once here rather than three times slightly differently.
class GridGeometry {
  const GridGeometry({
    required this.count,
    required this.pitch,
    required this.origin,
  });

  /// The biggest grid of [count] squares a side that fits in [space].
  factory GridGeometry.fit(Size space, int count) {
    // A parent that gives the board no height, which a phone screen never
    // does but a test or a scrolling column can.
    final width = space.width.isFinite ? space.width : _unbounded;
    final height = space.height.isFinite ? space.height : _unbounded;

    final pitch = math.max(1.0, math.min(width, height) / (count + 2 * margin));
    final side = pitch * count;
    return GridGeometry(
      count: count,
      pitch: pitch,
      origin: Offset((width - side) / 2, (height - side) / 2),
    );
  }

  static const _unbounded = 320.0;

  /// Room left around the grid, measured in squares, so the slab behind it has
  /// an edge and the outer letters are not jammed against the border.
  static const margin = 0.2;

  /// How close to the middle of a square a thumb has to be to take it, as a
  /// fraction of [pitch].
  ///
  /// This is the number that stops a drag between two squares picking up the
  /// pair it passes between: the centres of those two sit 0.71 of a square off
  /// the line the thumb takes, which is well outside this. Anything much
  /// larger and cutting a corner grabs letters nobody meant to trace;
  /// anything much smaller and a thumb has to be surgical.
  static const reach = 0.42;

  final int count;

  /// Centre to centre. A square is smaller than this by [gap].
  final double pitch;
  final Offset origin;

  double get gap => pitch * 0.13;
  double get side => pitch - gap;
  double get corner => pitch * 0.22;

  Rect get grid =>
      Rect.fromLTWH(origin.dx, origin.dy, pitch * count, pitch * count);

  Rect get panel => grid.inflate(pitch * margin);

  Offset centreOf(Spot spot) => Offset(
        origin.dx + (spot.col + 0.5) * pitch,
        origin.dy + (spot.row + 0.5) * pitch,
      );

  Rect squareOf(Spot spot) =>
      Rect.fromCenter(center: centreOf(spot), width: side, height: side);

  /// The square this point takes, or null if it is between squares or off the
  /// board altogether.
  Spot? claim(Offset point) {
    final col = ((point.dx - origin.dx) / pitch).floor();
    final row = ((point.dy - origin.dy) / pitch).floor();
    if (row < 0 || row >= count || col < 0 || col >= count) return null;
    final spot = Spot(row, col);
    return (point - centreOf(spot)).distance <= pitch * reach ? spot : null;
  }
}
