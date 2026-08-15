import 'dart:collection';

/// The arithmetic of the yard: eight wagons and an empty berth on a
/// three-by-three, a shunt sliding a wagon beside the gap into it. Two
/// voices: the walk, every arrangement the shunts can reach from home,
/// found breadth first with its fewest shunts; and the count of pairs
/// out of order, which every shunt leaves even or odd as it found it,
/// so an arrangement can be shunted home exactly when its count is
/// even.
class Rules {
  /// Home: the wagons in order, the gap at the bottom right.
  static const home = [1, 2, 3, 4, 5, 6, 7, 8, 0];

  /// An arrangement as one number, base nine.
  static int key(List<int> yard) {
    var k = 0;
    for (var i = 8; i >= 0; i--) {
      k = k * 9 + yard[i];
    }
    return k;
  }

  static List<int> unkey(int k) {
    final out = List.filled(9, 0);
    for (var i = 0; i < 9; i++) {
      out[i] = k % 9;
      k ~/= 9;
    }
    return out;
  }

  /// The berths beside berth [i].
  static List<int> beside(int i) {
    final r = i ~/ 3, c = i % 3;
    return [
      if (r > 0) i - 3,
      if (r < 2) i + 3,
      if (c > 0) i - 1,
      if (c < 2) i + 1,
    ];
  }

  /// The arrangement after the wagon at berth [from] is shunted into
  /// the gap, or null when it does not lie beside it.
  static List<int>? shunt(List<int> yard, int from) {
    final gap = yard.indexOf(0);
    if (!beside(gap).contains(from)) return null;
    final out = List.of(yard);
    out[gap] = yard[from];
    out[from] = 0;
    return out;
  }

  /// The count of pairs of wagons out of order, the gap left out.
  static int inversions(List<int> yard) {
    final tiles = yard.where((t) => t != 0).toList();
    var n = 0;
    for (var i = 0; i < tiles.length; i++) {
      for (var j = i + 1; j < tiles.length; j++) {
        if (tiles[i] > tiles[j]) n++;
      }
    }
    return n;
  }

  /// Whether the count says the arrangement can be shunted home.
  static bool evenByCount(List<int> yard) => inversions(yard).isEven;

  static Map<int, int>? _distances;

  /// The fewest shunts from every reachable arrangement to home, found
  /// once by walking out from home breadth first.
  static Map<int, int> get distances {
    if (_distances != null) return _distances!;
    final dist = <int, int>{key(home): 0};
    final queue = Queue<List<int>>()..add(home);
    while (queue.isNotEmpty) {
      final yard = queue.removeFirst();
      final d = dist[key(yard)]!;
      final gap = yard.indexOf(0);
      for (final from in beside(gap)) {
        final next = shunt(yard, from)!;
        final k = key(next);
        if (dist.containsKey(k)) continue;
        dist[k] = d + 1;
        queue.add(next);
      }
    }
    return _distances = dist;
  }

  /// The fewest shunts home from [yard], or null when it can never get
  /// there.
  static int? fewest(List<int> yard) => distances[key(yard)];

  static bool reachable(List<int> yard) => distances.containsKey(key(yard));

  /// The berth to shunt next on a shortest way home, or null at home or
  /// when there is no way.
  static int? next(List<int> yard) {
    final d = fewest(yard);
    if (d == null || d == 0) return null;
    final gap = yard.indexOf(0);
    for (final from in beside(gap)) {
      final n = shunt(yard, from)!;
      if (fewest(n) == d - 1) return from;
    }
    return null;
  }

  /// Every arrangement of the nine, as keys: 9! of them.
  static Iterable<List<int>> get allYards sync* {
    final yard = List.filled(9, 0);
    final used = List.filled(9, false);
    Iterable<List<int>> go(int i) sync* {
      if (i == 9) {
        yield List.of(yard);
        return;
      }
      for (var t = 0; t < 9; t++) {
        if (used[t]) continue;
        used[t] = true;
        yard[i] = t;
        yield* go(i + 1);
        used[t] = false;
      }
    }

    yield* go(0);
  }

  /// The arrangement told: '1 2 3 / 4 5 6 / 7 8 _'.
  static String told(List<int> yard) => [
        for (var r = 0; r < 3; r++) [for (var c = 0; c < 3; c++) yard[r * 3 + c] == 0 ? '_' : '${yard[r * 3 + c]}'].join(' '),
      ].join(' / ');
}
