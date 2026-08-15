/// The law of the green: hamlets stand on the points of a square grid,
/// and lanes run straight between them; two lanes cross when they meet
/// anywhere but at a hamlet they share, and a lane may not run through
/// a hamlet that is not its own. A green laid out with no crossing is
/// a straight-line drawing of its lanes as a planar graph, and Fary's
/// theorem says every planar graph has one; Euler's formula says which
/// never do: with v hamlets and e lanes, e is at most 3v - 6, and when
/// every ring of lanes has four at least, as it must when the hamlets
/// are of two kinds and lanes run only between the kinds, e is at most
/// 2v - 4. Three and three, every one to every one, is nine lanes over
/// six hamlets, and 2v - 4 is eight.
///
/// All the geometry is in whole numbers: cross products decide every
/// crossing, and nothing is ever rounded.
class Rules {
  /// The sign of the turn from a to b to c: left, straight, right.
  static int turn((int, int) a, (int, int) b, (int, int) c) {
    final d = (b.$1 - a.$1) * (c.$2 - a.$2) - (b.$2 - a.$2) * (c.$1 - a.$1);
    return d > 0 ? 1 : d < 0 ? -1 : 0;
  }

  /// Whether point [p] lies on the segment a to b, ends included.
  static bool onSegment((int, int) a, (int, int) b, (int, int) p) {
    if (turn(a, b, p) != 0) return false;
    return p.$1 >= (a.$1 < b.$1 ? a.$1 : b.$1) && p.$1 <= (a.$1 > b.$1 ? a.$1 : b.$1) && p.$2 >= (a.$2 < b.$2 ? a.$2 : b.$2) && p.$2 <= (a.$2 > b.$2 ? a.$2 : b.$2);
  }

  /// Whether the lanes a-b and c-d cross: they meet at a point that is
  /// not a shared hamlet. Lanes sharing a hamlet cross only if they
  /// overlap along a line.
  static bool cross((int, int) a, (int, int) b, (int, int) c, (int, int) d) {
    final shared = a == c || a == d || b == c || b == d;
    if (shared) {
      // The same lane, or lanes out of one hamlet: they cross only by
      // running along each other.
      final other1 = a == c || a == d ? b : a;
      final other2 = c == a || c == b ? d : c;
      final hub = a == c || a == d ? a : b;
      return turn(hub, other1, other2) == 0 && ((other1.$1 - hub.$1) * (other2.$1 - hub.$1) + (other1.$2 - hub.$2) * (other2.$2 - hub.$2)) > 0;
    }
    final t1 = turn(a, b, c), t2 = turn(a, b, d), t3 = turn(c, d, a), t4 = turn(c, d, b);
    if (t1 * t2 < 0 && t3 * t4 < 0) return true;
    // Touching or overlapping along a line counts as crossing too.
    if (t1 == 0 && onSegment(a, b, c)) return true;
    if (t2 == 0 && onSegment(a, b, d)) return true;
    if (t3 == 0 && onSegment(c, d, a)) return true;
    if (t4 == 0 && onSegment(c, d, b)) return true;
    return false;
  }

  /// The pairs of lanes that cross, and the lanes that run through a
  /// hamlet not their own, for [lanes] over hamlets at [at].
  static List<(int, int)> crossings(List<(int, int)> lanes, List<(int, int)> at) {
    final out = <(int, int)>[];
    for (var i = 0; i < lanes.length; i++) {
      for (var j = i + 1; j < lanes.length; j++) {
        final (a, b) = lanes[i];
        final (c, d) = lanes[j];
        if (cross(at[a], at[b], at[c], at[d])) out.add((i, j));
      }
    }
    return out;
  }

  /// The lanes that run through a hamlet not their own: (lane, hamlet).
  static List<(int, int)> throughs(List<(int, int)> lanes, List<(int, int)> at) {
    final out = <(int, int)>[];
    for (var i = 0; i < lanes.length; i++) {
      final (a, b) = lanes[i];
      for (var h = 0; h < at.length; h++) {
        if (h == a || h == b) continue;
        if (onSegment(at[a], at[b], at[h])) out.add((i, h));
      }
    }
    return out;
  }

  /// Whether the green is clear: no crossing and no lane through a hamlet.
  static bool clear(List<(int, int)> lanes, List<(int, int)> at) => crossings(lanes, at).isEmpty && throughs(lanes, at).isEmpty;

  /// Every placing of the hamlets on the [size] by [size] grid with the
  /// green clear, counted, with the count of all placings; the search
  /// places hamlets one at a time and stops at the first crossing among
  /// the lanes placed so far. [atMost] stops the search early, for the
  /// first clear placing.
  static (int, int, List<(int, int)>?) sweep(int hamlets, List<(int, int)> lanes, int size, {int? atMost}) {
    final points = [for (var y = 0; y < size; y++) for (var x = 0; x < size; x++) (x, y)];
    var all = 1;
    for (var i = 0; i < hamlets; i++) {
      all *= points.length - i;
    }
    final at = List<(int, int)>.filled(hamlets, (0, 0));
    final used = List<bool>.filled(points.length, false);
    var clearCount = 0;
    List<(int, int)>? first;
    bool okSoFar(int placed) {
      // Lanes among the placed hamlets, checked pairwise and for
      // hamlets on them.
      final done = <(int, int)>[];
      for (final (a, b) in lanes) {
        if (a < placed && b < placed) done.add((a, b));
      }
      for (var i = 0; i < done.length; i++) {
        final (a, b) = done[i];
        for (var h = 0; h < placed; h++) {
          if (h != a && h != b && onSegment(at[a], at[b], at[h])) return false;
        }
        for (var j = i + 1; j < done.length; j++) {
          final (c, d) = done[j];
          if (cross(at[a], at[b], at[c], at[d])) return false;
        }
      }
      return true;
    }

    void place(int h) {
      if (atMost != null && clearCount >= atMost) return;
      if (h == hamlets) {
        clearCount++;
        first ??= List.of(at);
        return;
      }
      for (var p = 0; p < points.length; p++) {
        if (used[p]) continue;
        used[p] = true;
        at[h] = points[p];
        if (okSoFar(h + 1)) place(h + 1);
        used[p] = false;
      }
    }

    place(0);
    return (clearCount, all, first);
  }

  /// Euler's ceiling on the lanes of a green that can be laid out clear:
  /// 3v - 6, or 2v - 4 when the hamlets are of two kinds with lanes only
  /// between the kinds (every ring then has four lanes at least).
  static int ceiling(int hamlets, {required bool twoKinds}) => twoKinds ? 2 * hamlets - 4 : 3 * hamlets - 6;
}
