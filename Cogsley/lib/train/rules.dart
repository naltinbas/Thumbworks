/// The law of the train: gears on the pegs of a board, each a whole
/// number of units across from its peg to its teeth, its teeth eight to
/// the unit. Two gears mesh when the distance between their pegs is the
/// sum of their radii exactly, and they overlap when it is less, which is
/// not allowed. Every mesh turns the next gear the other way, so a gear
/// an even number of meshes from the crank turns with it and an odd
/// number against it, and a ring of gears turns only when it has an
/// even number of gears, since round an odd ring the direction would
/// have to be both; a train with an odd ring jams. A gear that turns
/// makes crank turns times the crank's radius over its own, whatever
/// gears lie between: an idler changes nothing but the way.
class Rules {
  /// A gear on the board: peg (x, y) and radius r.
  static bool mesh((int, int, int) a, (int, int, int) b) {
    final dx = a.$1 - b.$1, dy = a.$2 - b.$2, s = a.$3 + b.$3;
    return dx * dx + dy * dy == s * s;
  }

  static bool overlap((int, int, int) a, (int, int, int) b) {
    final dx = a.$1 - b.$1, dy = a.$2 - b.$2, s = a.$3 + b.$3;
    return dx * dx + dy * dy < s * s;
  }

  /// Whether the gears sit apart, no two overlapping.
  static bool apart(List<(int, int, int)> gears) {
    for (var i = 0; i < gears.length; i++) {
      for (var j = i + 1; j < gears.length; j++) {
        if (overlap(gears[i], gears[j])) return false;
      }
    }
    return true;
  }

  /// The train from gear [crank] (an index): each gear's way, +1 with the
  /// crank, -1 against, 0 if it does not turn; and whether the train
  /// jams, some gear asked to turn both ways.
  static (List<int>, bool) turning(List<(int, int, int)> gears, int crank) {
    final way = List.filled(gears.length, 0);
    way[crank] = 1;
    final queue = [crank];
    var jam = false;
    while (queue.isNotEmpty) {
      final g = queue.removeAt(0);
      for (var h = 0; h < gears.length; h++) {
        if (h == g || !mesh(gears[g], gears[h])) continue;
        if (way[h] == 0) {
          way[h] = -way[g];
          queue.add(h);
        } else if (way[h] != -way[g]) {
          jam = true;
        }
      }
    }
    return (way, jam);
  }

  /// A gear's turns for one turn of the crank, as (numerator,
  /// denominator), for a gear that turns in a train that does not jam:
  /// the crank's radius over its own.
  static (int, int) speed((int, int, int) crank, (int, int, int) gear) {
    final g = _gcd(crank.$3, gear.$3);
    return (crank.$3 ~/ g, gear.$3 ~/ g);
  }

  /// The same speed walked mesh by mesh: each mesh passes the teeth
  /// speed along, so a gear's turns are its neighbour's turns times the
  /// neighbour's radius over its own; walked from the crank along any
  /// path, the same the way of every path when the train does not jam.
  static (int, int)? speedWalked(List<(int, int, int)> gears, int crank, int target) {
    final turns = List<(int, int)?>.filled(gears.length, null);
    turns[crank] = (1, 1);
    final queue = [crank];
    while (queue.isNotEmpty) {
      final g = queue.removeAt(0);
      for (var h = 0; h < gears.length; h++) {
        if (h == g || !mesh(gears[g], gears[h]) || turns[h] != null) continue;
        final (n, d) = turns[g]!;
        final num = n * gears[g].$3, den = d * gears[h].$3;
        final k = _gcd(num, den);
        turns[h] = (num ~/ k, den ~/ k);
        queue.add(h);
      }
    }
    return turns[target];
  }

  static int _gcd(int a, int b) => b == 0 ? a : _gcd(b, a % b);

  /// Whether the mesh graph holds a ring through gear [g]: a cycle.
  static bool inRing(List<(int, int, int)> gears, int g) {
    // A ring through g: some two neighbours of g joined without g.
    final nbrs = [for (var h = 0; h < gears.length; h++) if (h != g && mesh(gears[g], gears[h])) h];
    for (var i = 0; i < nbrs.length; i++) {
      for (var j = i + 1; j < nbrs.length; j++) {
        // Path from nbrs[i] to nbrs[j] avoiding g.
        final seen = {nbrs[i], g};
        final stack = [nbrs[i]];
        while (stack.isNotEmpty) {
          final c = stack.removeLast();
          if (c == nbrs[j]) return true;
          for (var h = 0; h < gears.length; h++) {
            if (h != c && !seen.contains(h) && mesh(gears[c], gears[h])) {
              seen.add(h);
              stack.add(h);
            }
          }
        }
      }
    }
    return false;
  }

  /// Every placing of the tray's gears, radii [tray], on the free pegs
  /// of a [w] by [h] board, beside the [fixed] gears, gears of a radius
  /// alike, all apart; asked, and how many meet the ask, with the count
  /// of placings, and the first that meets it.
  static (int, int, List<(int, int, int)>?) sweep(int w, int h, List<(int, int, int)> fixed, List<int> tray, bool Function(List<(int, int, int)> all) ask) {
    final pegs = [for (var y = 0; y < h; y++) for (var x = 0; x < w; x++) (x, y)];
    final free = pegs.where((p) => !fixed.any((f) => f.$1 == p.$1 && f.$2 == p.$2)).toList();
    var all = 0, met = 0;
    List<(int, int, int)>? first;
    final seen = <String>{};
    final placed = <(int, int, int)>[];
    void place(int i) {
      if (i == tray.length) {
        final key = (placed.map((g) => '${g.$1},${g.$2},${g.$3}').toList()..sort()).join('|');
        if (!seen.add(key)) return;
        all++;
        final gears = [...fixed, ...placed];
        if (ask(gears)) {
          met++;
          first ??= List.of(gears);
        }
        return;
      }
      for (final p in free) {
        if (placed.any((g) => g.$1 == p.$1 && g.$2 == p.$2)) continue;
        final gear = (p.$1, p.$2, tray[i]);
        if ([...fixed, ...placed].any((g) => overlap(g, gear))) continue;
        placed.add(gear);
        place(i + 1);
        placed.removeLast();
      }
    }

    place(0);
    return (met, all, first);
  }
}
