import 'dart:math' as math;

/// The law of the hall.
///
/// A hall is a simple ring of corners, its walls running corner to
/// corner. A ward posted at a corner lights every flag of the floor
/// it can see: the straight line between them crossing no wall and
/// leaving the hall nowhere.
///
/// How few wards a hall needs is known two ways that share nothing.
/// The sweep posts every set of corners there is, smallest first,
/// and keeps the first that lights the whole floor; the
/// three-colouring never counts a flag: cut the hall into
/// triangles, colour the corners three ways so no triangle repeats
/// one, and the scarcest colour is a watch that lights everything,
/// at most a third of the corners. The suite proves each against
/// the other on every hall that ships.
class Rules {
  static int _turn((int, int) from, (int, int) by, (int, int) to) =>
      (by.$1 - from.$1) * (to.$2 - from.$2) -
      (by.$2 - from.$2) * (to.$1 - from.$1);

  static bool _onWall((int, int) a, (int, int) b, (int, int) p) {
    if (_turn(a, b, p) != 0) return false;
    return p.$1 >= math.min(a.$1, b.$1) &&
        p.$1 <= math.max(a.$1, b.$1) &&
        p.$2 >= math.min(a.$2, b.$2) &&
        p.$2 <= math.max(a.$2, b.$2);
  }

  static bool _properCross(
      (int, int) a, (int, int) b, (int, int) c, (int, int) d) {
    final one = _turn(a, b, c);
    final two = _turn(a, b, d);
    final three = _turn(c, d, a);
    final four = _turn(c, d, b);
    return (one > 0) != (two > 0) &&
        (three > 0) != (four > 0) &&
        one != 0 &&
        two != 0 &&
        three != 0 &&
        four != 0;
  }

  /// Whether a point lies in the hall, walls counted in.
  static bool inHall(List<(int, int)> hall, (int, int) p) {
    for (var at = 0; at < hall.length; at++) {
      if (_onWall(hall[at], hall[(at + 1) % hall.length], p)) {
        return true;
      }
    }
    var hits = 0;
    for (var at = 0; at < hall.length; at++) {
      final (x1, y1) = hall[at];
      final (x2, y2) = hall[(at + 1) % hall.length];
      if ((y1 > p.$2) != (y2 > p.$2)) {
        final side =
            (p.$2 - y1) * (x2 - x1) - (p.$1 - x1) * (y2 - y1);
        if (side != 0 && (y2 - y1 > 0) == (side > 0)) hits++;
      }
    }
    return hits.isOdd;
  }

  /// Whether a ward at [ward] lights the flag at [flag].
  static bool lights(
      List<(int, int)> hall, (int, int) ward, (int, int) flag) {
    if (ward == flag) return true;
    for (var at = 0; at < hall.length; at++) {
      if (_properCross(
          ward, flag, hall[at], hall[(at + 1) % hall.length])) {
        return false;
      }
    }
    // The line's middle must lie in the hall: worked at doubled
    // scale so it stays in whole numbers.
    final doubled = [
      for (final (x, y) in hall) (2 * x, 2 * y),
    ];
    return inHall(
        doubled, (ward.$1 + flag.$1, ward.$2 + flag.$2));
  }

  /// Every flag of the floor: the whole-number points of the hall,
  /// walls counted in.
  static List<(int, int)> floorOf(List<(int, int)> hall) {
    var lowX = hall.first.$1, highX = lowX;
    var lowY = hall.first.$2, highY = lowY;
    for (final (x, y) in hall) {
      lowX = math.min(lowX, x);
      highX = math.max(highX, x);
      lowY = math.min(lowY, y);
      highY = math.max(highY, y);
    }
    return [
      for (var x = lowX; x <= highX; x++)
        for (var y = lowY; y <= highY; y++)
          if (inHall(hall, (x, y))) (x, y),
    ];
  }

  /// The flags a set of corner wards fails to light.
  static List<(int, int)> unlit(
      List<(int, int)> hall, List<int> wards) {
    final floor = floorOf(hall);
    return [
      for (final flag in floor)
        if (!wards.any((at) => lights(hall, hall[at], flag))) flag,
    ];
  }

  /// The fewest corner wards that light the whole floor, swept
  /// smallest first.
  static int fewestWards(List<(int, int)> hall) {
    final corners = hall.length;
    for (var count = 1; count <= corners; count++) {
      final picks = List<int>.generate(count, (at) => at);
      while (true) {
        if (unlit(hall, picks).isEmpty) return count;
        var at = count - 1;
        while (at >= 0 && picks[at] == corners - count + at) {
          at--;
        }
        if (at < 0) break;
        picks[at]++;
        for (var after = at + 1; after < count; after++) {
          picks[after] = picks[after - 1] + 1;
        }
      }
    }
    return corners;
  }

  /// The hall cut into triangles by ear clipping: corner index
  /// triples. The hall must wind counterclockwise.
  static List<(int, int, int)> triangles(List<(int, int)> hall) {
    final left = List<int>.generate(hall.length, (at) => at);
    final cut = <(int, int, int)>[];
    while (left.length > 3) {
      var clipped = false;
      for (var at = 0; at < left.length && !clipped; at++) {
        final before = left[(at + left.length - 1) % left.length];
        final here = left[at];
        final after = left[(at + 1) % left.length];
        if (_turn(hall[before], hall[here], hall[after]) <= 0) {
          continue;
        }
        var empty = true;
        for (final other in left) {
          if (other == before || other == here || other == after) {
            continue;
          }
          if (_inTriangle(
              hall[before], hall[here], hall[after], hall[other])) {
            empty = false;
            break;
          }
        }
        if (!empty) continue;
        cut.add((before, here, after));
        left.removeAt(at);
        clipped = true;
      }
      if (!clipped) break;
    }
    if (left.length == 3) {
      cut.add((left[0], left[1], left[2]));
    }
    return cut;
  }

  static bool _inTriangle((int, int) a, (int, int) b, (int, int) c,
      (int, int) p) {
    final one = _turn(a, b, p);
    final two = _turn(b, c, p);
    final three = _turn(c, a, p);
    return one >= 0 && two >= 0 && three >= 0;
  }

  /// The corners coloured three ways so no triangle repeats one,
  /// worked triangle by triangle from the cutting.
  static List<int> threeColours(List<(int, int)> hall) {
    final cut = triangles(hall);
    final colour = List<int>.filled(hall.length, -1);
    // The last triangle clipped seeds the colours; ears colour
    // backward, each ear's tip forced by its two neighbours.
    for (final (a, b, c) in cut.reversed) {
      final unset = [
        if (colour[a] == -1) a,
        if (colour[b] == -1) b,
        if (colour[c] == -1) c,
      ];
      if (unset.length == 3) {
        colour[a] = 0;
        colour[b] = 1;
        colour[c] = 2;
      } else {
        for (final corner in unset) {
          final used = {
            for (final other in [a, b, c])
              if (colour[other] != -1) colour[other],
          };
          colour[corner] =
              [0, 1, 2].firstWhere((paint) => !used.contains(paint));
        }
      }
    }
    return colour;
  }

  /// The scarcest colour's corners: a watch of at most a third of
  /// them, by the three-colouring alone.
  static List<int> fiskWatch(List<(int, int)> hall) {
    final colour = threeColours(hall);
    final byColour = [<int>[], <int>[], <int>[]];
    for (var at = 0; at < hall.length; at++) {
      byColour[colour[at]].add(at);
    }
    byColour.sort((a, b) => a.length.compareTo(b.length));
    return byColour.first;
  }
}
