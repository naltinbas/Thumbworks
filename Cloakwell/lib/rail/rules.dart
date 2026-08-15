import 'dart:collection';

/// The law of the rail: coats numbered on hooks in a row, swapped two
/// neighbours at a time, and sorted when they run 1, 2, 3... along.
class Rules {
  /// Pairs out of order: a coat and a smaller one somewhere to its right.
  static int inversions(List<int> row) {
    var n = 0;
    for (var i = 0; i < row.length; i++) {
      for (var j = i + 1; j < row.length; j++) {
        if (row[i] > row[j]) n++;
      }
    }
    return n;
  }

  static bool sorted(List<int> row) => inversions(row) == 0;

  /// The row with hooks [i] and [i + 1] swapped.
  static List<int> swapped(List<int> row, int i) {
    final out = List.of(row);
    final t = out[i];
    out[i] = out[i + 1];
    out[i + 1] = t;
    return out;
  }

  /// The fewest swaps that sort the row, by walking every row it can
  /// reach, nearest first.
  static int fewestBySearch(List<int> row) {
    final seen = <String>{'$row'};
    final queue = Queue<(List<int>, int)>()..add((row, 0));
    while (queue.isNotEmpty) {
      final (r, d) = queue.removeFirst();
      if (sorted(r)) return d;
      for (var i = 0; i + 1 < r.length; i++) {
        final next = swapped(r, i);
        if (seen.add('$next')) queue.add((next, d + 1));
      }
    }
    return -1;
  }

  /// The sign of the row as a permutation, by its cycles: even when the
  /// coats can be sorted by an even number of swaps of any two.
  static int signByCycles(List<int> row) {
    final n = row.length;
    final seen = List.filled(n, false);
    var transpositions = 0;
    for (var i = 0; i < n; i++) {
      if (seen[i]) continue;
      var length = 0;
      var j = i;
      while (!seen[j]) {
        seen[j] = true;
        j = row[j] - 1;
        length++;
      }
      transpositions += length - 1;
    }
    return transpositions.isEven ? 1 : -1;
  }

  /// Every sequence of [length] swaps of neighbours, and how many sort
  /// the row.
  static (int sorting, int all) sequences(List<int> row, int length) {
    var sorting = 0, all = 0;
    void grow(List<int> r, int left) {
      if (left == 0) {
        all++;
        if (sorted(r)) sorting++;
        return;
      }
      for (var i = 0; i + 1 < r.length; i++) {
        grow(swapped(r, i), left - 1);
      }
    }

    grow(row, length);
    return (sorting, all);
  }

  /// A descent: a hook whose coat is bigger than the next one's; a swap
  /// there fixes exactly one pair. The first, or null when sorted.
  static int? firstDescent(List<int> row) {
    for (var i = 0; i + 1 < row.length; i++) {
      if (row[i] > row[i + 1]) return i;
    }
    return null;
  }

  /// Every arrangement of 1..n, visited in turn.
  static void rows(int n, void Function(List<int>) visit) {
    final row = <int>[];
    final used = List.filled(n + 1, false);
    void grow() {
      if (row.length == n) {
        visit(row);
        return;
      }
      for (var v = 1; v <= n; v++) {
        if (used[v]) continue;
        used[v] = true;
        row.add(v);
        grow();
        row.removeLast();
        used[v] = false;
      }
    }

    grow();
  }
}
