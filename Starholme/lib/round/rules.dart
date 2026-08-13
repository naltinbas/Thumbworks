/// The law of the star.
///
/// Ten posts: five on the outer ring, five on the inner star,
/// a spoke joining each pair, fifteen lanes in all. This is
/// Petersen's graph, and its rounds are counted whole: twelve
/// pentagons, ten hexagons, fifteen eights, twenty nines,
/// never a seven-round, and never the full ten. Yet drop any
/// one post and exactly two nine-post tours remain: the twenty
/// nines are those tours, two per post left out.
class Rules {
  /// Every lane, low post first.
  static List<(int, int)> get lanes {
    final held = <(int, int)>[];
    for (var i = 0; i < 5; i++) {
      held.add(_sorted(i, (i + 1) % 5));
      held.add(_sorted(5 + i, 5 + (i + 2) % 5));
      held.add(_sorted(i, 5 + i));
    }
    return held;
  }

  static (int, int) _sorted(int a, int b) => a < b ? (a, b) : (b, a);

  /// Whether two posts share a lane.
  static bool beside(int a, int b) => lanes.contains(_sorted(a, b));

  /// The posts beside a post.
  static List<int> around(int post) => [
        for (var other = 0; other < 10; other++)
          if (beside(post, other)) other,
      ];

  /// Whether a closed walk is a sound round: three posts or
  /// more, none twice, every step and the closing step a lane.
  static bool sound(List<int> walk) {
    if (walk.length < 3) return false;
    if (walk.toSet().length != walk.length) return false;
    for (var at = 0; at < walk.length; at++) {
      if (!beside(walk[at], walk[(at + 1) % walk.length])) {
        return false;
      }
    }
    return true;
  }

  /// Every round of [posts] posts, each counted once; calls
  /// [visit] with one walking of it. The sweep the checker and
  /// the suite share.
  static void rounds(int posts, void Function(List<int>) visit) {
    void walk(int start, List<int> path, Set<int> seen) {
      if (path.length == posts) {
        if (beside(path.last, start) && path[1] < path.last) {
          visit(path);
        }
        return;
      }
      for (final next in around(path.last)) {
        if (next > start && !seen.contains(next)) {
          seen.add(next);
          path.add(next);
          walk(start, path, seen);
          path.removeLast();
          seen.remove(next);
        }
      }
    }

    for (var start = 0; start < 10; start++) {
      walk(start, [start], {start});
    }
  }

  /// How many rounds of [posts] posts stand.
  static int waysTo(int posts) {
    var ways = 0;
    rounds(posts, (_) => ways++);
    return ways;
  }

  /// One round of [posts] posts, or null: drives the show-me.
  static List<int>? round(int posts) {
    List<int>? found;
    rounds(posts, (walk) {
      found ??= List.of(walk);
    });
    return found;
  }

  /// The nine-rounds sorted by the post they leave out: the
  /// hypohamiltonian law, two per post.
  static Map<int, int> ninesByLeftOut() {
    final left = <int, int>{};
    rounds(9, (walk) {
      final out = [
        for (var post = 0; post < 10; post++)
          if (!walk.contains(post)) post,
      ].single;
      left[out] = (left[out] ?? 0) + 1;
    });
    return left;
  }

  /// The census over every length: true when the counts stand
  /// where the labels say and nothing else appears.
  static bool lawsHold() {
    final wanted = {3: 0, 4: 0, 5: 12, 6: 10, 7: 0, 8: 15, 9: 20, 10: 0};
    for (final entry in wanted.entries) {
      if (waysTo(entry.key) != entry.value) return false;
    }
    final nines = ninesByLeftOut();
    if (nines.length != 10) return false;
    if (nines.values.any((count) => count != 2)) return false;
    return true;
  }
}
