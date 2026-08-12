/// The law of the web.
///
/// Posts stand in a ring, a thread between every pair. Two weavers
/// take turns claiming threads, and whoever closes a triangle of
/// three own threads loses at once. On five posts the whole web can
/// fill with nobody caught; on six it cannot, and a sweep of every
/// painting says so, with the counting argument run as code besides.
class Rules {
  Rules(this.dots) {
    edges = [
      for (var a = 0; a < dots; a++)
        for (var b = a + 1; b < dots; b++) (a, b),
    ];
    int at(int a, int b) =>
        edges.indexWhere((edge) => edge == (a, b));
    triangles = [
      for (var a = 0; a < dots; a++)
        for (var b = a + 1; b < dots; b++)
          for (var c = b + 1; c < dots; c++)
            (at(a, b), at(a, c), at(b, c)),
    ];
  }

  final int dots;

  late final List<(int, int)> edges;

  /// Every triangle, as three thread indexes.
  late final List<(int, int, int)> triangles;

  int get threads => edges.length;

  /// The triangle a thread would close among held threads, or null.
  (int, int, int)? closing(int held, int thread) {
    final all = held | (1 << thread);
    for (final (x, y, z) in triangles) {
      if (thread != x && thread != y && thread != z) continue;
      if (all & (1 << x) != 0 &&
          all & (1 << y) != 0 &&
          all & (1 << z) != 0) {
        return (x, y, z);
      }
    }
    return null;
  }

  final _memo = <int, int>{};

  /// The side to move's standing with best weaving: 1 wins, 0 draws,
  /// -1 loses.
  int value(int mine, int theirs) {
    final key = mine | (theirs << threads);
    final known = _memo[key];
    if (known != null) return known;
    var best = -2;
    var canMove = false;
    for (var thread = 0; thread < threads; thread++) {
      final bit = 1 << thread;
      if ((mine | theirs) & bit != 0) continue;
      canMove = true;
      if (closing(mine, thread) != null) continue;
      final reply = -value(theirs, mine | bit);
      if (reply > best) best = reply;
      if (best == 1) break;
    }
    if (!canMove) return _memo[key] = 0;
    if (best == -2) best = -1;
    return _memo[key] = best;
  }

  /// The best thread for the side to move: winning if any, else
  /// drawing, else the longest-lasting safe thread, else any.
  int bestThread(int mine, int theirs) {
    var bestValue = -2;
    var best = -1;
    for (var thread = 0; thread < threads; thread++) {
      final bit = 1 << thread;
      if ((mine | theirs) & bit != 0) continue;
      if (best < 0) best = thread;
      if (closing(mine, thread) != null) continue;
      final reply = -value(theirs, mine | bit);
      if (reply > bestValue) {
        bestValue = reply;
        best = thread;
      }
    }
    return best;
  }

  /// How many full paintings of the web hold no one-colour triangle.
  int safePaintings() {
    var safe = 0;
    for (var paint = 0; paint < (1 << threads); paint++) {
      if (!_holdsMono(paint)) safe++;
    }
    return safe;
  }

  bool _holdsMono(int paint) {
    for (final (x, y, z) in triangles) {
      final a = (paint >> x) & 1;
      final b = (paint >> y) & 1;
      final c = (paint >> z) & 1;
      if (a == b && b == c) return true;
    }
    return false;
  }

  /// The counting argument, run as code on a full six-post painting:
  /// of post nought's five threads, three share a colour; among those
  /// three far posts, any thread of the shared colour closes a
  /// triangle with post nought, and if none is, the three are a
  /// triangle of the other colour. Returns a one-colour triangle.
  (int, int, int) pigeonTriangle(int paint) {
    assert(dots == 6);
    int at(int a, int b) => edges.indexWhere(
        (edge) => edge == (a < b ? (a, b) : (b, a)));
    // Post nought's threads, split by colour.
    final sameColour = <int>[];
    final colourOf = <int, int>{};
    for (var post = 1; post < dots; post++) {
      colourOf[post] = (paint >> at(0, post)) & 1;
    }
    for (final colour in const [0, 1]) {
      final posts = [
        for (var post = 1; post < dots; post++)
          if (colourOf[post] == colour) post,
      ];
      if (posts.length >= 3) {
        sameColour.addAll(posts.take(3));
        // Any same-colour thread among the three closes with nought.
        final colourHeld = colour;
        for (var one = 0; one < 3; one++) {
          for (var other = one + 1; other < 3; other++) {
            final thread = at(sameColour[one], sameColour[other]);
            if ((paint >> thread) & 1 == colourHeld) {
              return (
                at(0, sameColour[one]),
                at(0, sameColour[other]),
                thread,
              );
            }
          }
        }
        // None was: the three mutual threads are all the other
        // colour.
        return (
          at(sameColour[0], sameColour[1]),
          at(sameColour[0], sameColour[2]),
          at(sameColour[1], sameColour[2]),
        );
      }
    }
    throw StateError('five threads must share a colour three ways');
  }

  /// Whether a full painting's colour classes are each one ring
  /// round all the posts: every post carrying exactly two threads of
  /// each colour.
  bool isRingAndStar(int paint) {
    for (var post = 0; post < dots; post++) {
      var one = 0;
      for (var other = 0; other < dots; other++) {
        if (other == post) continue;
        final thread = edges.indexWhere((edge) =>
            edge == (post < other ? (post, other) : (other, post)));
        if ((paint >> thread) & 1 == 1) one++;
      }
      if (one != 2) return false;
    }
    return true;
  }
}
