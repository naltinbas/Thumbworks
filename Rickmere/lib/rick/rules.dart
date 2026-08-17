import 'frac.dart';
import 'root3.dart';

/// A field with three corner posts on a peg green, and a hayrick
/// raised on each of its three sides: an even triangle, built outward,
/// with a marker at its centre.
///
/// Wherever the posts stand, the three markers make an even triangle of
/// their own. Rutherford printed it in The Ladies' Diary in 1825 and it
/// has carried Napoleon's name ever since.
class Rules {
  /// The green is this many pegs each way.
  static const pegs = 5;

  /// Where the posts stand when a go opens.
  static const opening = [(0, 2), (1, 1), (2, 1)];

  static bool onGreen((int, int) at) =>
      at.$1 >= 0 && at.$1 < pegs && at.$2 >= 0 && at.$2 < pegs;

  /// Twice the signed area of the field, which is a whole number on a
  /// peg green and says which way round the posts run.
  static int twiceArea(List<(int, int)> posts) {
    final (ax, ay) = posts[0];
    final (bx, by) = posts[1];
    final (cx, cy) = posts[2];
    return (bx - ax) * (cy - ay) - (by - ay) * (cx - ax);
  }

  /// Whether the three posts make a field at all: three pegs, none on
  /// top of another, and not in a line.
  static bool isField(List<(int, int)> posts) {
    if (posts.length != 3) return false;
    if (!posts.every(onGreen)) return false;
    if (posts[0] == posts[1] || posts[1] == posts[2] || posts[0] == posts[2]) {
      return false;
    }
    return twiceArea(posts) != 0;
  }

  /// The far corner of the even triangle raised on the side from [p] to
  /// [q]. Turning the side by sixty degrees one way or the other is
  /// what raises it, and [turn] says which way, so that outward always
  /// means away from the field however the posts run.
  static (Root3, Root3) rickCorner((int, int) p, (int, int) q, int turn) {
    final dx = Root3.of(q.$1 - p.$1);
    final dy = Root3.of(q.$2 - p.$2);
    final half = Root3(Frac.of(1, 2), Frac.zero);
    final up = Root3(Frac.zero, Frac.of(1, 2));
    final down = Root3(Frac.zero, Frac.of(-1, 2));
    final Root3 rx, ry;
    if (turn > 0) {
      rx = dx * half + dy * up;
      ry = dx * down + dy * half;
    } else {
      rx = dx * half + dy * down;
      ry = dx * up + dy * half;
    }
    return (Root3.of(p.$1) + rx, Root3.of(p.$2) + ry);
  }

  /// The marker at the middle of the rick raised on the side from [p]
  /// to [q].
  static (Root3, Root3) marker((int, int) p, (int, int) q, int turn) {
    final corner = rickCorner(p, q, turn);
    return (
      (Root3.of(p.$1) + Root3.of(q.$1) + corner.$1).over(3),
      (Root3.of(p.$2) + Root3.of(q.$2) + corner.$2).over(3),
    );
  }

  /// Which way the ricks are raised so that outward means away from the
  /// field.
  static int outward(List<(int, int)> posts) => twiceArea(posts) > 0 ? 1 : -1;

  /// The three markers, in the order of the sides.
  static List<(Root3, Root3)> markers(List<(int, int)> posts,
      {bool out = true}) {
    final turn = out ? outward(posts) : -outward(posts);
    return [
      marker(posts[0], posts[1], turn),
      marker(posts[1], posts[2], turn),
      marker(posts[2], posts[0], turn),
    ];
  }

  /// The three corners of the ricks, in the order of the sides.
  static List<(Root3, Root3)> rickCorners(List<(int, int)> posts,
      {bool out = true}) {
    final turn = out ? outward(posts) : -outward(posts);
    return [
      rickCorner(posts[0], posts[1], turn),
      rickCorner(posts[1], posts[2], turn),
      rickCorner(posts[2], posts[0], turn),
    ];
  }

  /// The square of the distance between two markers, exactly.
  static Root3 apart((Root3, Root3) u, (Root3, Root3) v) {
    final dx = u.$1 - v.$1;
    final dy = u.$2 - v.$2;
    return dx * dx + dy * dy;
  }

  /// The three sides of the marker triangle, squared.
  static List<Root3> markerSides(List<(int, int)> posts, {bool out = true}) {
    final m = markers(posts, out: out);
    return [apart(m[0], m[1]), apart(m[1], m[2]), apart(m[2], m[0])];
  }

  /// The first voice: are the three markers the same distance apart?
  static bool evenByLength(List<(int, int)> posts, {bool out = true}) {
    final sides = markerSides(posts, out: out);
    return sides[0] == sides[1] && sides[1] == sides[2];
  }

  /// The second voice, which measures nothing: turn the first marker
  /// sixty degrees about the second and see whether it lands on the
  /// third. Only an even triangle does that.
  static bool evenByTurning(List<(int, int)> posts, {bool out = true}) {
    final m = markers(posts, out: out);
    for (final turn in [1, -1]) {
      if (turnedOnto(m[0], m[1], turn) == m[2]) return true;
    }
    return false;
  }

  /// [about] as the pivot, [what] turned sixty degrees about it.
  static (Root3, Root3) turnedOnto(
      (Root3, Root3) what, (Root3, Root3) about, int turn) {
    final dx = what.$1 - about.$1;
    final dy = what.$2 - about.$2;
    final half = Root3(Frac.of(1, 2), Frac.zero);
    final up = Root3(Frac.zero, Frac.of(1, 2));
    final down = Root3(Frac.zero, Frac.of(-1, 2));
    final Root3 rx, ry;
    if (turn > 0) {
      rx = dx * half + dy * down;
      ry = dx * up + dy * half;
    } else {
      rx = dx * half + dy * up;
      ry = dx * down + dy * half;
    }
    return (about.$1 + rx, about.$2 + ry);
  }

  /// Twice the signed area of a triangle whose corners carry roots.
  static Root3 twiceAreaOf(List<(Root3, Root3)> corners) {
    final ab = (corners[1].$1 - corners[0].$1, corners[1].$2 - corners[0].$2);
    final ac = (corners[2].$1 - corners[0].$1, corners[2].$2 - corners[0].$2);
    return ab.$1 * ac.$2 - ab.$2 * ac.$1;
  }

  /// Every field the green holds.
  static List<List<(int, int)>> fields() {
    final all = <List<(int, int)>>[];
    final green = [
      for (var x = 0; x < pegs; x++)
        for (var y = 0; y < pegs; y++) (x, y),
    ];
    for (var i = 0; i < green.length; i++) {
      for (var j = i + 1; j < green.length; j++) {
        for (var k = j + 1; k < green.length; k++) {
          final posts = [green[i], green[j], green[k]];
          if (isField(posts)) all.add(posts);
        }
      }
    }
    return all;
  }

  /// The widest the markers ever stand apart on this green, squared:
  /// (32 and 16 roots of three) over 3, which the four fields on the
  /// corners of the green reach.
  static Root3 get widest =>
      Root3(Frac.of(32, 3), Frac.of(16, 3));

  /// The squares of the field's own three sides, which are whole
  /// numbers.
  static List<int> fieldSides(List<(int, int)> posts) {
    int gap((int, int) p, (int, int) q) =>
        (p.$1 - q.$1) * (p.$1 - q.$1) + (p.$2 - q.$2) * (p.$2 - q.$2);
    return [
      gap(posts[0], posts[1]),
      gap(posts[1], posts[2]),
      gap(posts[2], posts[0]),
    ]..sort();
  }

  /// Whether the field has a square corner.
  static bool squareCorner(List<(int, int)> posts) {
    final s = fieldSides(posts);
    return s[0] + s[1] == s[2];
  }

  /// The field's area, in half acres, so that it stays a whole number.
  static int halfAcres(List<(int, int)> posts) => twiceArea(posts).abs();

  /// The posts that have to be moved to get from one field to another,
  /// whichever way the second is written down.
  static int moves(List<(int, int)> from, List<(int, int)> to) {
    var best = 3;
    for (final order in [
      [0, 1, 2],
      [0, 2, 1],
      [1, 0, 2],
      [1, 2, 0],
      [2, 0, 1],
      [2, 1, 0],
    ]) {
      var n = 0;
      for (var i = 0; i < 3; i++) {
        if (from[i] != to[order[i]]) n++;
      }
      if (n < best) best = n;
    }
    return best;
  }

  static String tellPosts(List<(int, int)> posts) =>
      [for (final p in posts) '(${p.$1}, ${p.$2})'].join(', ');
}
