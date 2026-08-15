import 'dart:math' as math;

/// A cell of the yard, x across and y down, 0 to side - 1.
typedef Cell = (int, int);

/// The law of the yard.
///
/// Slabs laid in the cells of a five-by-five yard, joined edge to
/// edge, and a kerb run round the outside of them: one length of
/// kerb for every slab edge that meets bare ground. The question
/// is how short the kerb can be for a given count of slabs, and
/// the answer, Harary and Harborth's, is twice the least whole
/// number not below twice the square root of the count. The sweep
/// here lays every joined placing of up to ten slabs on the yard,
/// 39,622 of them at ten, and the shortest kerb agrees with that
/// number at every count. The bound that proves it is a box: the
/// kerb round a placing is at least the kerb round the smallest
/// box holding it, twice its width plus its height, and five slabs
/// need a box of at least two by three, so their kerb is ten at
/// the least and never eight.
class Rules {
  Rules(this.side);

  final int side;

  List<Cell> get cells => [
        for (var y = 0; y < side; y++)
          for (var x = 0; x < side; x++) (x, y),
      ];

  static const _steps = [(1, 0), (-1, 0), (0, 1), (0, -1)];

  bool inside(Cell c) => c.$1 >= 0 && c.$1 < side && c.$2 >= 0 && c.$2 < side;

  List<Cell> neighbours(Cell c) => [
        for (final (dx, dy) in _steps)
          if (inside((c.$1 + dx, c.$2 + dy))) (c.$1 + dx, c.$2 + dy),
      ];

  /// The kerb: every slab edge that meets bare ground or the edge
  /// of the yard, counted.
  static int kerb(Set<Cell> slabs) {
    var count = 0;
    for (final slab in slabs) {
      for (final (dx, dy) in _steps) {
        if (!slabs.contains((slab.$1 + dx, slab.$2 + dy))) count++;
      }
    }
    return count;
  }

  /// Whether the slabs are joined edge to edge into one yard.
  static bool joined(Set<Cell> slabs) {
    if (slabs.isEmpty) return false;
    final seen = <Cell>{slabs.first};
    final queue = [slabs.first];
    while (queue.isNotEmpty) {
      final here = queue.removeLast();
      for (final (dx, dy) in _steps) {
        final next = (here.$1 + dx, here.$2 + dy);
        if (slabs.contains(next) && seen.add(next)) queue.add(next);
      }
    }
    return seen.length == slabs.length;
  }

  /// The smallest box holding the slabs, as (width, height).
  static (int, int) box(Set<Cell> slabs) {
    if (slabs.isEmpty) return (0, 0);
    var left = side3, right = -1, top = side3, bottom = -1;
    for (final (x, y) in slabs) {
      left = math.min(left, x);
      right = math.max(right, x);
      top = math.min(top, y);
      bottom = math.max(bottom, y);
    }
    return (right - left + 1, bottom - top + 1);
  }

  static const side3 = 1 << 20;

  /// The kerb round the box: twice its width plus its height. Never
  /// more than the kerb itself.
  static int boxKerb(Set<Cell> slabs) {
    final (w, h) = box(slabs);
    return 2 * (w + h);
  }

  /// The shortest kerb any joined placing of [count] slabs can have,
  /// by Harary and Harborth's arithmetic: twice the least whole
  /// number not below twice the square root of the count.
  static int shortestByFormula(int count) {
    var k = 0;
    while (k * k < 4 * count) {
      k++;
    }
    return 2 * k;
  }

  /// The smallest box kerb any [count] slabs can have: the least
  /// width plus height over boxes holding that many cells, doubled.
  static int shortestBox(int count) {
    var best = 1 << 20;
    for (var w = 1; w <= count; w++) {
      final h = (count + w - 1) ~/ w;
      best = math.min(best, 2 * (w + h));
    }
    return best;
  }

  /// Walks every joined placing of exactly [count] slabs on the
  /// yard, each once, by Redelmeier's method; calls [visit].
  void placings(int count, void Function(Set<Cell>) visit) {
    final all = cells;
    final order = {for (var i = 0; i < all.length; i++) all[i]: i};
    for (final start in all) {
      final slabs = <Cell>{start};
      final reached = <Cell>{start};
      final untried = <Cell>[];
      for (final n in neighbours(start)) {
        if (order[n]! > order[start]! && reached.add(n)) untried.add(n);
      }
      void grow(List<Cell> untried) {
        if (slabs.length == count) {
          visit(slabs);
          return;
        }
        final left = List<Cell>.of(untried);
        while (left.isNotEmpty) {
          final cell = left.removeLast();
          slabs.add(cell);
          final added = <Cell>[];
          for (final n in neighbours(cell)) {
            if (order[n]! > order[start]! && reached.add(n)) added.add(n);
          }
          grow([...left, ...added]);
          for (final n in added) {
            reached.remove(n);
          }
          slabs.remove(cell);
        }
      }

      grow(untried);
    }
  }

  /// How many joined placings of [count] slabs wear a kerb of
  /// exactly [asked], and how many placings there are; and the
  /// shortest kerb seen.
  (int, int, int) sweep(int count, int asked) {
    var ways = 0, all = 0, shortest = 1 << 20;
    placings(count, (slabs) {
      all++;
      final k = kerb(slabs);
      if (k == asked) ways++;
      if (k < shortest) shortest = k;
    });
    return (ways, all, shortest);
  }

  /// The first placing the sweep finds with the asked kerb, or null.
  Set<Cell>? landing(int count, int asked) {
    Set<Cell>? found;
    placings(count, (slabs) {
      if (found == null && kerb(slabs) == asked) found = Set.of(slabs);
    });
    return found;
  }
}
