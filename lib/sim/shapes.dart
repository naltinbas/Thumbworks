import 'dart:math';

/// A point, or a direction. Units, never pixels: the simulation does not know
/// how big a phone is and the view does not know any physics.
class Spot {
  const Spot(this.x, this.y);

  static const zero = Spot(0, 0);

  final double x;
  final double y;

  Spot operator +(Spot o) => Spot(x + o.x, y + o.y);
  Spot operator -(Spot o) => Spot(x - o.x, y - o.y);
  Spot operator *(double k) => Spot(x * k, y * k);
  Spot operator -() => Spot(-x, -y);

  double get lengthSquared => x * x + y * y;
  double get length => sqrt(lengthSquared);

  Spot get unit {
    final size = length;
    return size == 0 ? zero : Spot(x / size, y / size);
  }

  /// Turned a quarter turn.
  Spot get across => Spot(-y, x);

  double dot(Spot o) => x * o.x + y * o.y;

  @override
  bool operator ==(Object other) =>
      other is Spot && other.x == x && other.y == y;

  @override
  int get hashCode => Object.hash(x, y);

  @override
  String toString() => '(${x.toStringAsFixed(2)}, ${y.toStringAsFixed(2)})';
}

/// A straight piece of something solid.
class Line {
  const Line(this.from, this.to);

  final Spot from;
  final Spot to;

  double get length => (to - from).length;

  Spot get along => (to - from).unit;

  /// The point on this line closest to [spot].
  ///
  /// Clamped to the ends, which is what makes a line a line and not an
  /// infinite one: a ball past the end of a ledge should fall off it, and the
  /// difference between those two behaviours is this one clamp.
  Spot nearestTo(Spot spot) {
    final run = to - from;
    final size = run.lengthSquared;
    if (size == 0) return from;
    final howFar = ((spot - from).dot(run) / size).clamp(0.0, 1.0);
    return from + run * howFar;
  }

  double distanceTo(Spot spot) => (spot - nearestTo(spot)).length;

  @override
  String toString() => '$from-$to';
}

/// A round thing: the ball, the goal, a spike.
class Blob {
  const Blob(this.at, this.radius);

  final Spot at;
  final double radius;

  bool holds(Spot spot) => (spot - at).length <= radius;

  bool touches(Spot spot, double otherRadius) =>
      (spot - at).length <= radius + otherRadius;
}
