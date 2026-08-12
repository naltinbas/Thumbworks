/// The law of the marsh.
///
/// Posts stand on the crossings of a four-by-four marsh, no three
/// ever sharing a line. A frame is four posts standing true: each
/// one outside the triangle of the other three, so the four
/// corner a quadrilateral with nothing tucked inside.
///
/// The happy ending theorem is the law: five posts, none three
/// to a line, always hold a frame. It is checked two ways that
/// share nothing, on every four: the tuck test asks whether some
/// post sits inside the others' triangle, and the hull walk asks
/// whether the four can be ordered so every turn bends the same
/// way. The sweep stands every setting there is and holds the
/// two together. The suite refuses the bake the moment any two
/// part ways.
class Rules {
  static const side = 4;

  /// Every crossing of the marsh.
  static List<(int, int)> get marsh => [
        for (var x = 0; x < side; x++)
          for (var y = 0; y < side; y++) (x, y),
      ];

  static int _turn((int, int) a, (int, int) b, (int, int) c) =>
      (b.$1 - a.$1) * (c.$2 - a.$2) -
      (b.$2 - a.$2) * (c.$1 - a.$1);

  /// The triples of posts sharing a line.
  static List<((int, int), (int, int), (int, int))> shared(
      List<(int, int)> posts) {
    final lined = <((int, int), (int, int), (int, int))>[];
    for (var a = 0; a < posts.length; a++) {
      for (var b = a + 1; b < posts.length; b++) {
        for (var c = b + 1; c < posts.length; c++) {
          if (_turn(posts[a], posts[b], posts[c]) == 0) {
            lined.add((posts[a], posts[b], posts[c]));
          }
        }
      }
    }
    return lined;
  }

  static bool clearStanding(List<(int, int)> posts) =>
      shared(posts).isEmpty;

  /// The tuck test: true when the four stand true, no three on a
  /// line and no post inside the others' triangle.
  static bool trueByTuck(List<(int, int)> four) {
    for (var a = 0; a < 4; a++) {
      for (var b = a + 1; b < 4; b++) {
        for (var c = b + 1; c < 4; c++) {
          if (_turn(four[a], four[b], four[c]) == 0) return false;
        }
      }
    }
    for (var at = 0; at < 4; at++) {
      final post = four[at];
      final rest = [
        for (var other = 0; other < 4; other++)
          if (other != at) four[other],
      ];
      final base = _turn(rest[0], rest[1], rest[2]);
      final one = _turn(rest[0], rest[1], post);
      final two = _turn(rest[1], rest[2], post);
      final three = _turn(rest[2], rest[0], post);
      if (base != 0 &&
          (one > 0) == (base > 0) &&
          (two > 0) == (base > 0) &&
          (three > 0) == (base > 0)) {
        return false;
      }
    }
    return true;
  }

  /// The hull walk: true when some ordering of the four turns the
  /// same way at every corner.
  static bool trueByWalk(List<(int, int)> four) {
    final orders = <List<int>>[
      [0, 1, 2, 3],
      [0, 1, 3, 2],
      [0, 2, 1, 3],
    ];
    for (final order in orders) {
      final ring = [for (final at in order) four[at]];
      var bends = true;
      int? way;
      for (var corner = 0; corner < 4; corner++) {
        final turn = _turn(
          ring[corner],
          ring[(corner + 1) % 4],
          ring[(corner + 2) % 4],
        );
        if (turn == 0) {
          bends = false;
          break;
        }
        final sign = turn > 0 ? 1 : -1;
        if (way == null) {
          way = sign;
        } else if (way != sign) {
          bends = false;
          break;
        }
      }
      if (bends) return true;
    }
    return false;
  }

  /// The frames among the posts: every four standing true, by the
  /// tuck test.
  static List<List<(int, int)>> frames(List<(int, int)> posts) {
    final found = <List<(int, int)>>[];
    for (var a = 0; a < posts.length; a++) {
      for (var b = a + 1; b < posts.length; b++) {
        for (var c = b + 1; c < posts.length; c++) {
          for (var d = c + 1; d < posts.length; d++) {
            final four = [posts[a], posts[b], posts[c], posts[d]];
            if (trueByTuck(four)) found.add(four);
          }
        }
      }
    }
    return found;
  }

  /// Every setting of [count] posts, walked; calls [visit] with
  /// each. The sweep the checker and the suite share.
  static void settings(
      int count, void Function(List<(int, int)>) visit) {
    final spots = marsh;
    final picked = <(int, int)>[];
    void walk(int from) {
      if (picked.length == count) {
        visit(picked);
        return;
      }
      for (var at = from; at < spots.length; at++) {
        picked.add(spots[at]);
        walk(at + 1);
        picked.removeLast();
      }
    }

    walk(0);
  }

  /// How many clear settings of [count] posts show exactly
  /// [asked] frames.
  static int waysTo(int count, int asked) {
    var ways = 0;
    settings(count, (posts) {
      if (!clearStanding(posts)) return;
      if (frames(posts).length == asked) ways++;
    });
    return ways;
  }

  /// One clear setting landing [asked], or null.
  static List<(int, int)>? setting(int count, int asked) {
    List<(int, int)>? found;
    settings(count, (posts) {
      if (found != null || !clearStanding(posts)) return;
      if (frames(posts).length == asked) found = List.of(posts);
    });
    return found;
  }

  /// Whether the law holds over the whole sweep: the two truth
  /// tests agree on every four, and no clear five lacks a frame.
  static bool lawHolds() {
    var sound = true;
    settings(4, (posts) {
      if (trueByTuck(posts) != trueByWalk(posts)) sound = false;
    });
    settings(5, (posts) {
      if (!clearStanding(posts)) return;
      if (frames(posts).isEmpty) sound = false;
    });
    return sound;
  }
}
