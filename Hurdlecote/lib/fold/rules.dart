import 'dart:math' as math;

/// The law of the fence.
///
/// The green is a square of crossings where the mowing lines meet. A
/// fence is hurdles set at crossings, each rail running straight to
/// the next, the last rail closing back on the first. A fence must
/// stand simple: no rail crosses another, no hurdle stands on a rail
/// not its own.
///
/// What a fence pens is known two ways that share nothing. The
/// shoelace walks the hurdles and reckons twice the acreage from
/// coordinates alone; Pick counts crossings, the penned and the
/// walked, and says acreage = penned + walked / 2 - 1. The suite
/// proves the two against each other on every simple fence of the
/// green, and twice the shoelace count is always a whole number,
/// which is why a third of an acre is beyond every fence there is.
class Rules {
  /// Twice the acreage a closed fence pens, by the shoelace.
  static int area2(List<(int, int)> posts) {
    var sum = 0;
    for (var at = 0; at < posts.length; at++) {
      final (x1, y1) = posts[at];
      final (x2, y2) = posts[(at + 1) % posts.length];
      sum += x1 * y2 - x2 * y1;
    }
    return sum.abs();
  }

  /// The crossings a closed fence's line walks, hurdles included.
  static int walked(List<(int, int)> posts) {
    var count = 0;
    for (var at = 0; at < posts.length; at++) {
      final (x1, y1) = posts[at];
      final (x2, y2) = posts[(at + 1) % posts.length];
      count += _gcd((x2 - x1).abs(), (y2 - y1).abs());
    }
    return count;
  }

  /// The crossings a closed fence pens strictly inside, counted one
  /// by one with a ray. Knows nothing of the shoelace.
  static int penned(List<(int, int)> posts) {
    var lowX = posts.first.$1, highX = lowX;
    var lowY = posts.first.$2, highY = lowY;
    for (final (x, y) in posts) {
      lowX = math.min(lowX, x);
      highX = math.max(highX, x);
      lowY = math.min(lowY, y);
      highY = math.max(highY, y);
    }
    var count = 0;
    for (var x = lowX; x <= highX; x++) {
      for (var y = lowY; y <= highY; y++) {
        if (onFence(posts, (x, y))) continue;
        if (_pennedIn(posts, (x, y))) count++;
      }
    }
    return count;
  }

  /// Whether a crossing off the line lies inside: a ray cast
  /// rightward cuts an odd count of rails.
  static bool _pennedIn(List<(int, int)> posts, (int, int) spot) {
    final (x, y) = spot;
    var cuts = 0;
    for (var at = 0; at < posts.length; at++) {
      final (x1, y1) = posts[at];
      final (x2, y2) = posts[(at + 1) % posts.length];
      if ((y1 > y) != (y2 > y)) {
        // Does the rail cross the ray to the right of the spot?
        // Kept in whole numbers: compare cross-multiplied.
        final side = (y - y1) * (x2 - x1) - (x - x1) * (y2 - y1);
        if (y2 - y1 > 0 ? side > 0 : side < 0) cuts++;
      }
    }
    return cuts.isOdd;
  }

  /// Whether a crossing lies on the closed fence's line.
  static bool onFence(List<(int, int)> posts, (int, int) spot) {
    for (var at = 0; at < posts.length; at++) {
      if (_onRail(posts[at], posts[(at + 1) % posts.length], spot)) {
        return true;
      }
    }
    return false;
  }

  static bool _onRail((int, int) a, (int, int) b, (int, int) spot) {
    if (_turn(a, b, spot) != 0) return false;
    return spot.$1 >= math.min(a.$1, b.$1) &&
        spot.$1 <= math.max(a.$1, b.$1) &&
        spot.$2 >= math.min(a.$2, b.$2) &&
        spot.$2 <= math.max(a.$2, b.$2);
  }

  static int _turn((int, int) from, (int, int) by, (int, int) to) =>
      (by.$1 - from.$1) * (to.$2 - from.$2) -
      (by.$2 - from.$2) * (to.$1 - from.$1);

  /// Whether two rails share any point at all.
  static bool _railsTouch(
      (int, int) a, (int, int) b, (int, int) c, (int, int) d) {
    final one = _turn(a, b, c);
    final two = _turn(a, b, d);
    final three = _turn(c, d, a);
    final four = _turn(c, d, b);
    if ((one > 0) != (two > 0) &&
        (three > 0) != (four > 0) &&
        one != 0 &&
        two != 0 &&
        three != 0 &&
        four != 0) {
      return true;
    }
    return _onRail(a, b, c) ||
        _onRail(a, b, d) ||
        _onRail(c, d, a) ||
        _onRail(c, d, b);
  }

  /// Whether the fence would double straight back at [by].
  static bool _foldsBack(
          (int, int) from, (int, int) by, (int, int) to) =>
      _turn(from, by, to) == 0 &&
      (by.$1 - from.$1) * (to.$1 - by.$1) +
              (by.$2 - from.$2) * (to.$2 - by.$2) <
          0;

  /// Whether a closed run of hurdles stands as a simple fence.
  static bool standsClosed(List<(int, int)> posts) {
    final count = posts.length;
    if (count < 3) return false;
    if (posts.toSet().length != count) return false;
    for (var at = 0; at < count; at++) {
      final a = posts[at];
      final b = posts[(at + 1) % count];
      for (var other = 0; other < count; other++) {
        if (other == at || other == (at + 1) % count) continue;
        if (_onRail(a, b, posts[other])) return false;
      }
    }
    for (var at = 0; at < count; at++) {
      final a = posts[at];
      final b = posts[(at + 1) % count];
      for (var other = at + 1; other < count; other++) {
        if ((other + 1) % count == at || (at + 1) % count == other) {
          continue;
        }
        if (_railsTouch(a, b, posts[other], posts[(other + 1) % count])) {
          return false;
        }
      }
    }
    for (var at = 0; at < count; at++) {
      if (_foldsBack(posts[(at + count - 1) % count], posts[at],
          posts[(at + 1) % count])) {
        return false;
      }
    }
    return area2(posts) != 0;
  }

  /// Whether one more hurdle can be set at [next], its new rail
  /// clearing everything already stood.
  static bool maySet(List<(int, int)> posts, (int, int) next) {
    if (posts.contains(next)) return false;
    if (posts.isEmpty) return true;
    final last = posts.last;
    for (var at = 0; at + 2 < posts.length; at++) {
      if (_railsTouch(posts[at], posts[at + 1], last, next)) {
        return false;
      }
    }
    if (posts.length >= 2) {
      final beforeLast = posts[posts.length - 2];
      if (_foldsBack(beforeLast, last, next)) return false;
      if (_onRail(last, next, beforeLast)) return false;
    }
    for (final post in posts) {
      if (post == last) continue;
      if (_onRail(last, next, post)) return false;
    }
    return true;
  }

  /// Whether the open run can close into a standing fence now.
  static bool mayClose(List<(int, int)> posts) =>
      posts.length >= 3 && standsClosed(posts);

  /// Every simple fence of up to [most] hurdles on a green of
  /// [size] by [size] crossings. Each fence is told once: begun at
  /// its smallest hurdle, taken the way round that keeps the
  /// smaller second hurdle.
  static List<List<(int, int)>> everyFence(int size, int most) {
    final spots = [
      for (var x = 0; x < size; x++)
        for (var y = 0; y < size; y++) (x, y),
    ];
    final fences = <List<(int, int)>>[];
    final run = <(int, int)>[];
    final used = <int>{};

    void grow(int firstAt) {
      if (run.length >= 3 &&
          _id(run[1]) < _id(run.last) &&
          standsClosed(run)) {
        fences.add(List.of(run));
      }
      if (run.length == most) return;
      for (var at = firstAt + 1; at < spots.length; at++) {
        if (used.contains(at)) continue;
        if (!maySet(run, spots[at])) continue;
        run.add(spots[at]);
        used.add(at);
        grow(firstAt);
        run.removeLast();
        used.remove(at);
      }
    }

    for (var firstAt = 0; firstAt < spots.length; firstAt++) {
      run.add(spots[firstAt]);
      used.add(firstAt);
      grow(firstAt);
      used.remove(firstAt);
      run.removeLast();
    }
    return fences;
  }

  /// Grows the open run into any fence that settles [isDone], using
  /// at most [most] hurdles in all; the finished run, or null.
  static List<(int, int)>? complete(
    int size,
    List<(int, int)> posts,
    int most,
    bool Function(List<(int, int)>) isDone,
  ) {
    final spots = [
      for (var x = 0; x < size; x++)
        for (var y = 0; y < size; y++) (x, y),
    ];
    final run = List.of(posts);

    List<(int, int)>? grow() {
      if (run.length >= 3 && standsClosed(run) && isDone(run)) {
        return List.of(run);
      }
      if (run.length == most) return null;
      for (final spot in spots) {
        if (run.contains(spot)) continue;
        if (!maySet(run, spot)) continue;
        run.add(spot);
        final found = grow();
        run.removeLast();
        if (found != null) return found;
      }
      return null;
    }

    return grow();
  }

  static int _id((int, int) spot) => spot.$1 * 100 + spot.$2;

  static int _gcd(int a, int b) => b == 0 ? a : _gcd(b, a % b);
}
