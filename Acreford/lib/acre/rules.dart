/// The law of the paddock.
///
/// Posts stand on a four-by-four grid. A paddock is a fence
/// walked post to post and closed, rails never touching except
/// where one hands the walk to the next. The acres inside are
/// counted two ways that share nothing: the rails' own crossing
/// sum, and Pick's 1899 count of the posts inside and on the
/// rim. The sweep walks every paddock of three and four posts,
/// all 2,806 of them, and the two counts agree on every one.
class Rules {
  static const side = 4;

  /// Every post of the field.
  static List<(int, int)> get field => [
        for (var x = 0; x < side; x++)
          for (var y = 0; y < side; y++) (x, y),
      ];

  static int _gcd(int a, int b) => b == 0 ? a : _gcd(b, a % b);

  static int _orient((int, int) p, (int, int) q, (int, int) r) {
    final v = (q.$1 - p.$1) * (r.$2 - p.$2) -
        (q.$2 - p.$2) * (r.$1 - p.$1);
    return v == 0 ? 0 : (v > 0 ? 1 : -1);
  }

  static bool _between(int a, int b, int p) =>
      (a <= p && p <= b) || (b <= p && p <= a);

  /// Whether [p] lies on the rail from [a] to [b], ends counted.
  static bool onRail((int, int) p, (int, int) a, (int, int) b) =>
      _orient(a, b, p) == 0 &&
      _between(a.$1, b.$1, p.$1) &&
      _between(a.$2, b.$2, p.$2);

  /// Whether two rails share any point at all.
  static bool railsTouch(
      (int, int) a, (int, int) b, (int, int) c, (int, int) d) {
    final o1 = _orient(a, b, c), o2 = _orient(a, b, d);
    final o3 = _orient(c, d, a), o4 = _orient(c, d, b);
    if (o1 != o2 && o3 != o4) return true;
    return onRail(c, a, b) ||
        onRail(d, a, b) ||
        onRail(a, c, d) ||
        onRail(b, c, d);
  }

  /// Whether a closed walk is a sound paddock: no post walked
  /// twice, no rail touching another except at the post they
  /// share, and no rail doubling back over its neighbour.
  static bool sound(List<(int, int)> walk) {
    final posts = walk.length;
    if (posts < 3) return false;
    if (walk.toSet().length != posts) return false;
    for (var i = 0; i < posts; i++) {
      final a = walk[i], b = walk[(i + 1) % posts];
      if (a == b) return false;
      for (var j = i + 1; j < posts; j++) {
        final c = walk[j], d = walk[(j + 1) % posts];
        final neighbours = (j == i + 1) || (i == 0 && j == posts - 1);
        if (neighbours) {
          // The shared post is the only meeting allowed.
          final shared = (j == i + 1) ? b : a;
          final farC = (j == i + 1) ? d : c;
          final farA = (j == i + 1) ? a : b;
          if (_orient(a, b, c) == 0 && _orient(a, b, d) == 0) {
            return false;
          }
          if (onRail(farC, a, b) && farC != shared) return false;
          if (onRail(farA, c, d) && farA != shared) return false;
        } else {
          if (railsTouch(a, b, c, d)) return false;
        }
      }
    }
    return true;
  }

  /// Whether an open walk is sound so far: every post a bend,
  /// rails touching only where one hands the walk to the next.
  static bool chainSound(List<(int, int)> walk) {
    final posts = walk.length;
    if (walk.toSet().length != posts) return false;
    for (var i = 0; i + 1 < posts; i++) {
      final a = walk[i], b = walk[i + 1];
      if (a == b) return false;
      for (var j = i + 1; j + 1 < posts; j++) {
        final c = walk[j], d = walk[j + 1];
        if (j == i + 1) {
          // Neighbouring rails: bend at the shared post, and
          // touch nowhere else.
          if (_orient(a, b, d) == 0 &&
              _orient(a, b, c) == 0) {
            return false;
          }
          if (onRail(d, a, b) && d != b) return false;
          if (onRail(a, c, d) && a != b) {
            if (a != c) return false;
          }
        } else {
          if (railsTouch(a, b, c, d)) return false;
        }
      }
    }
    return true;
  }

  /// Twice the acres, by the rails alone: the crossing sum.
  static int twiceAcres(List<(int, int)> walk) {
    var sum = 0;
    for (var i = 0; i < walk.length; i++) {
      final a = walk[i], b = walk[(i + 1) % walk.length];
      sum += a.$1 * b.$2 - b.$1 * a.$2;
    }
    return sum.abs();
  }

  /// The lattice steps one rail takes: gcd of its spans, which
  /// is one more than the posts it runs over mid-rail.
  static int railGap((int, int) a, (int, int) b) =>
      _gcd((b.$1 - a.$1).abs(), (b.$2 - a.$2).abs());

  /// The posts on the rim, walked posts and mid-rail posts both:
  /// each rail carries gcd of its spans.
  static int rimPosts(List<(int, int)> walk) {
    var rim = 0;
    for (var i = 0; i < walk.length; i++) {
      final a = walk[i], b = walk[(i + 1) % walk.length];
      rim += _gcd((b.$1 - a.$1).abs(), (b.$2 - a.$2).abs());
    }
    return rim;
  }

  /// The posts strictly inside, by casting a ray east from each
  /// and counting rails it crosses, all in whole numbers.
  static int insidePosts(List<(int, int)> walk) {
    var inside = 0;
    for (final post in field) {
      var onEdge = false;
      for (var i = 0; i < walk.length && !onEdge; i++) {
        onEdge = onRail(post, walk[i], walk[(i + 1) % walk.length]);
      }
      if (onEdge) continue;
      var crossings = 0;
      for (var i = 0; i < walk.length; i++) {
        final a = walk[i], b = walk[(i + 1) % walk.length];
        if ((a.$2 > post.$2) != (b.$2 > post.$2)) {
          final num = (a.$1 - post.$1) * (b.$2 - a.$2) +
              (post.$2 - a.$2) * (b.$1 - a.$1);
          if (b.$2 > a.$2 ? num > 0 : num < 0) crossings++;
        }
      }
      if (crossings.isOdd) inside++;
    }
    return inside;
  }

  /// The mid-rail posts: on the rim but never walked.
  static int midRailPosts(List<(int, int)> walk) =>
      rimPosts(walk) - walk.length;

  /// Pick's count: twice the inside posts, plus the rim, less two.
  static int twiceAcresByPick(List<(int, int)> walk) =>
      2 * insidePosts(walk) + rimPosts(walk) - 2;

  /// Every paddock of [posts] posts, each walked once; calls
  /// [visit] with each. The sweep the checker and the suite share.
  static void paddocks(
      int posts, void Function(List<(int, int)>) visit) {
    final spots = field;
    final chosen = <int>[];
    void chooseFrom(int from) {
      if (chosen.length == posts) {
        // Walk the chosen posts in every order that starts at
        // the first and runs its lowest neighbour clockwise of
        // the pair, so each paddock is visited exactly once.
        final head = spots[chosen[0]];
        final rest = [for (final at in chosen.skip(1)) spots[at]];
        void order(List<(int, int)> walk, List<(int, int)> left) {
          if (left.isEmpty) {
            // Keep one of each direction pair: second post
            // before the last.
            if (_lexLess(walk[1], walk[walk.length - 1]) &&
                sound(walk)) {
              visit(walk);
            }
            return;
          }
          for (var i = 0; i < left.length; i++) {
            order(
              [...walk, left[i]],
              [...left.sublist(0, i), ...left.sublist(i + 1)],
            );
          }
        }

        order([head], rest);
        return;
      }
      for (var at = from; at < spots.length; at++) {
        chosen.add(at);
        chooseFrom(at + 1);
        chosen.removeLast();
      }
    }

    chooseFrom(0);
  }

  static bool _lexLess((int, int) a, (int, int) b) =>
      a.$1 != b.$1 ? a.$1 < b.$1 : a.$2 < b.$2;

  /// How many paddocks land an asking.
  static int waysTo(
    int posts, {
    int? twoA,
    int? inside,
    bool? midRail,
  }) {
    var ways = 0;
    paddocks(posts, (walk) {
      if (lands(walk, twoA: twoA, inside: inside, midRail: midRail)) {
        ways++;
      }
    });
    return ways;
  }

  /// Whether one paddock lands an asking.
  static bool lands(
    List<(int, int)> walk, {
    int? twoA,
    int? inside,
    bool? midRail,
  }) {
    if (twoA != null && twiceAcres(walk) != twoA) return false;
    if (inside != null && insidePosts(walk) != inside) return false;
    if (midRail != null && (midRailPosts(walk) > 0) != midRail) {
      return false;
    }
    return true;
  }

  /// One paddock landing an asking, or null: drives the show-me.
  static List<(int, int)>? paddock(
    int posts, {
    int? twoA,
    int? inside,
    bool? midRail,
  }) {
    List<(int, int)>? found;
    paddocks(posts, (walk) {
      if (found == null &&
          lands(walk, twoA: twoA, inside: inside, midRail: midRail)) {
        found = List.of(walk);
      }
    });
    return found;
  }

  /// The two counts held together over every paddock of [posts]
  /// posts: true when nothing breaks.
  static bool pickHolds(int posts) {
    var holds = true;
    paddocks(posts, (walk) {
      if (twiceAcres(walk) != twiceAcresByPick(walk)) holds = false;
    });
    return holds;
  }
}
