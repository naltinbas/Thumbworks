/// The law of the wall: square frames, no two alike, hung edge to edge
/// to fill a rectangular wall exactly, which is a perfect squared
/// rectangle. The search hangs frames at the first bare cell, top row
/// first and left to right within it, since whatever frame covers that
/// cell must have its top left corner there; every hanging that fills
/// the wall is found that way, once each.
///
/// The smallest frame is never on the rim: on the rim its two
/// neighbours along the wall's edge, or one neighbour and the wall's
/// corner, are taller than it, so it sits at the bottom of a well as
/// wide as itself, and whatever frame covers the cell above it must
/// fit the well, so be no wider than it, and every other frame is
/// wider.
class Rules {
  /// A hanging: each frame's top left corner, by its size.
  static const int noFrame = -1;

  /// Every hanging of [sizes] that fills a [width] by [height] wall,
  /// each as a map from size to (x, y). With [fixed] some frames are
  /// hung already and stay; with [smallestOnRim] only hangings whose
  /// smallest frame touches the rim are kept. [byColumns] searches
  /// column by column instead, the second reading of the same count.
  static List<Map<int, (int, int)>> hangings(
    int width,
    int height,
    List<int> sizes, {
    Map<int, (int, int)> fixed = const {},
    bool smallestOnRim = false,
    bool byColumns = false,
    int? atMost,
  }) {
    final grid = List.generate(height, (_) => List.filled(width, noFrame));
    final placed = <int, (int, int)>{};
    final found = <Map<int, (int, int)>>[];
    final smallest = sizes.reduce((a, b) => a < b ? a : b);
    void set(int s, int x, int y, int value) {
      for (var j = y; j < y + s; j++) {
        for (var i = x; i < x + s; i++) {
          grid[j][i] = value;
        }
      }
    }

    bool free(int s, int x, int y) {
      if (x + s > width || y + s > height) return false;
      for (var j = y; j < y + s; j++) {
        for (var i = x; i < x + s; i++) {
          if (grid[j][i] != noFrame) return false;
        }
      }
      return true;
    }

    for (final entry in fixed.entries) {
      final (x, y) = entry.value;
      if (!free(entry.key, x, y)) throw StateError('fixed frames overlap');
      set(entry.key, x, y, entry.key);
      placed[entry.key] = (x, y);
    }
    final loose = sizes.where((s) => !fixed.containsKey(s)).toList()..sort((a, b) => b - a);

    (int, int)? firstBare() {
      if (byColumns) {
        for (var i = 0; i < width; i++) {
          for (var j = 0; j < height; j++) {
            if (grid[j][i] == noFrame) return (i, j);
          }
        }
      } else {
        for (var j = 0; j < height; j++) {
          for (var i = 0; i < width; i++) {
            if (grid[j][i] == noFrame) return (i, j);
          }
        }
      }
      return null;
    }

    void search() {
      if (atMost != null && found.length >= atMost) return;
      final bare = firstBare();
      if (bare == null) {
        found.add(Map.of(placed));
        return;
      }
      final (x, y) = bare;
      for (final s in loose) {
        if (placed.containsKey(s)) continue;
        if (!free(s, x, y)) continue;
        if (smallestOnRim && s == smallest && !touchesRim(width, height, s, x, y)) continue;
        set(s, x, y, s);
        placed[s] = (x, y);
        search();
        placed.remove(s);
        set(s, x, y, noFrame);
      }
    }

    search();
    return found;
  }

  /// Whether a frame of [s] at (x, y) touches the wall's rim.
  static bool touchesRim(int width, int height, int s, int x, int y) => x == 0 || y == 0 || x + s == width || y + s == height;

  /// The wall's four turnings and mirrorings applied to a hanging.
  static List<Map<int, (int, int)>> images(int width, int height, Map<int, (int, int)> hanging) {
    Map<int, (int, int)> apply((int, int) Function(int s, int x, int y) f) => {for (final e in hanging.entries) e.key: f(e.key, e.value.$1, e.value.$2)};
    return [
      hanging,
      apply((s, x, y) => (width - x - s, y)),
      apply((s, x, y) => (x, height - y - s)),
      apply((s, x, y) => (width - x - s, height - y - s)),
    ];
  }

  /// The Bouwkamp code of a hanging: the frames read off in the order
  /// the search hangs them, top row first, grouped by the run they make
  /// along the top of the bare region.
  static String bouwkamp(int width, int height, Map<int, (int, int)> hanging) {
    final grid = List.generate(height, (_) => List.filled(width, noFrame));
    for (final e in hanging.entries) {
      for (var j = e.value.$2; j < e.value.$2 + e.key; j++) {
        for (var i = e.value.$1; i < e.value.$1 + e.key; i++) {
          grid[j][i] = e.key;
        }
      }
    }
    final groups = <List<int>>[];
    final done = <int>{};
    while (done.length < hanging.length) {
      // The first bare cell of the hung-so-far picture: the frames
      // starting on that row from that cell rightward, edge to edge,
      // form one group.
      int? bx, by;
      for (var j = 0; j < height && bx == null; j++) {
        for (var i = 0; i < width; i++) {
          if (!done.contains(grid[j][i])) {
            bx = i;
            by = j;
            break;
          }
        }
      }
      final group = <int>[];
      var x = bx!;
      while (x < width && !done.contains(grid[by!][x]) && hanging[grid[by][x]]!.$2 == by && hanging[grid[by][x]]!.$1 == x) {
        final s = grid[by][x];
        group.add(s);
        done.add(s);
        x += s;
      }
      groups.add(group);
    }
    return groups.map((g) => '(${g.join(',')})').join('');
  }

  /// The frames touching frame [s] in a hanging, by size, in reading order.
  static List<int> neighbours(int width, int height, Map<int, (int, int)> hanging, int s) {
    final (x, y) = hanging[s]!;
    final near = <int>{};
    for (final e in hanging.entries) {
      if (e.key == s) continue;
      final (ox, oy) = e.value;
      final t = e.key;
      final touchX = ox + t == x || x + s == ox;
      final touchY = oy + t == y || y + s == oy;
      final overlapX = ox < x + s && x < ox + t;
      final overlapY = oy < y + s && y < oy + t;
      if ((touchX && overlapY) || (touchY && overlapX)) near.add(t);
    }
    return near.toList()..sort();
  }
}

/// Two hangings compared frame by frame, whatever order they were built in.
extension HangingWords on Map<int, (int, int)> {
  String get told {
    final keys = this.keys.toList()..sort();
    return keys.map((k) => '$k:${this[k]!.$1},${this[k]!.$2}').join(' ');
  }
}
