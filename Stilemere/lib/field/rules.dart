/// A junction of hedges: so many plots along, so many up, from the
/// gate at (0, 0).
typedef Junction = (int, int);

/// One hedged field: [width] plots along and [height] plots up, so
/// the junctions run from the gate at (0, 0) to the mill at (width,
/// height), and every step goes right or up.
class Field {
  const Field(this.width, this.height, {this.stiles = const [], this.ponds = const []});

  final int width;
  final int height;

  /// Junctions the walk must pass through.
  final List<Junction> stiles;

  /// Junctions the walk may not stand on.
  final List<Junction> ponds;

  Junction get gate => (0, 0);
  Junction get mill => (width, height);

  bool inside(Junction j) => j.$1 >= 0 && j.$1 <= width && j.$2 >= 0 && j.$2 <= height;

  bool isPond(Junction j) => ponds.contains(j);

  /// The steps out of [j]: right, then up, where they stay in the
  /// field and out of the ponds.
  List<Junction> stepsFrom(Junction j) => [
        for (final n in [(j.$1 + 1, j.$2), (j.$1, j.$2 + 1)])
          if (inside(n) && !isPond(n)) n,
      ];

  /// Whether a walk lands: gate to mill by steps, past every stile
  /// and no pond.
  bool lands(List<Junction> walk) {
    if (walk.isEmpty || walk.first != gate || walk.last != mill) return false;
    for (var i = 0; i + 1 < walk.length; i++) {
      if (!stepsFrom(walk[i]).contains(walk[i + 1])) return false;
    }
    if (walk.any(isPond)) return false;
    return stiles.every(walk.contains);
  }

  /// Every walk from [from] to the mill, ponds or no, visited in turn:
  /// right before up at every junction.
  void walks(void Function(List<Junction>) visit, {Junction? from, bool mindPonds = false}) {
    final walk = [from ?? gate];
    void grow() {
      final head = walk.last;
      if (head == mill) {
        visit(walk);
        return;
      }
      for (final n in [(head.$1 + 1, head.$2), (head.$1, head.$2 + 1)]) {
        if (!inside(n) || (mindPonds && isPond(n))) continue;
        walk.add(n);
        grow();
        walk.removeLast();
      }
    }

    grow();
  }

  /// The walks that land, and all the walks there are, counted by
  /// walking every one.
  (int, int) sweep() {
    var landing = 0, all = 0;
    walks((walk) {
      all++;
      if (lands(walk)) landing++;
    });
    return (landing, all);
  }

  /// The first landing walk, right before up, or null.
  List<Junction>? landing() {
    List<Junction>? found;
    walks((walk) {
      if (found == null && lands(walk)) found = List.of(walk);
    });
    return found;
  }

  /// Pascal's rule, junction by junction: the routes from the gate to
  /// each junction round the ponds, each the sum of the routes to the
  /// junction left of it and the one below.
  List<List<int>> routesFromGate() {
    final routes = List.generate(width + 1, (_) => List.filled(height + 1, 0));
    for (var x = 0; x <= width; x++) {
      for (var y = 0; y <= height; y++) {
        if (isPond((x, y))) continue;
        if (x == 0 && y == 0) {
          routes[x][y] = 1;
          continue;
        }
        routes[x][y] = (x > 0 ? routes[x - 1][y] : 0) + (y > 0 ? routes[x][y - 1] : 0);
      }
    }
    return routes;
  }

  /// The same rule run backwards: routes from each junction on to the
  /// mill round the ponds.
  List<List<int>> routesToMill() {
    final routes = List.generate(width + 1, (_) => List.filled(height + 1, 0));
    for (var x = width; x >= 0; x--) {
      for (var y = height; y >= 0; y--) {
        if (isPond((x, y))) continue;
        if (x == width && y == height) {
          routes[x][y] = 1;
          continue;
        }
        routes[x][y] = (x < width ? routes[x + 1][y] : 0) + (y < height ? routes[x][y + 1] : 0);
      }
    }
    return routes;
  }

  /// The landings on from [from], counted by walking: past every stile
  /// not yet passed, round the ponds.
  int landingsFrom(List<Junction> soFar) {
    var count = 0;
    walks((rest) {
      final whole = [...soFar, ...rest.skip(1)];
      if (lands(whole)) count++;
    }, from: soFar.last, mindPonds: true);
    return count;
  }

  /// The binomial coefficient, n choose k, by the multiplying rule.
  static int choose(int n, int k) {
    if (k < 0 || k > n) return 0;
    var out = 1;
    for (var i = 1; i <= k; i++) {
      out = out * (n - k + i) ~/ i;
    }
    return out;
  }

  /// The routes from one junction on to another with no ponds in the
  /// way, by the binomial: so many steps, choose which go right.
  static int between(Junction a, Junction b) {
    final dx = b.$1 - a.$1, dy = b.$2 - a.$2;
    if (dx < 0 || dy < 0) return 0;
    return choose(dx + dy, dx);
  }

  /// The routes past every stile in turn, gate to mill, by the
  /// multiplying rule alone: the stiles sorted along the walk, and
  /// nought when two cannot both be passed.
  int byStiles() {
    final sorted = List.of(stiles)..sort((a, b) => a.$1 != b.$1 ? a.$1 - b.$1 : a.$2 - b.$2);
    var count = 1;
    var at = gate;
    for (final s in [...sorted, mill]) {
      count *= between(at, s);
      at = s;
    }
    return count;
  }
}
