/// The law of the yard: n by n flags, numbered row by row from the top
/// left, and watchmen posted on flags; a watchman watches his own flag
/// and the eight round it, and the yard is watched when every flag is.
class Rules {
  const Rules(this.size);

  /// Flags along a side.
  final int size;

  int get flags => size * size;

  int rowOf(int c) => c ~/ size;

  int colOf(int c) => c % size;

  int at(int row, int col) => row * size + col;

  /// The flags a watchman on [c] watches, his own among them.
  List<int> watch(int c) => [
        for (var dr = -1; dr <= 1; dr++)
          for (var dc = -1; dc <= 1; dc++)
            if (rowOf(c) + dr >= 0 && rowOf(c) + dr < size && colOf(c) + dc >= 0 && colOf(c) + dc < size)
              at(rowOf(c) + dr, colOf(c) + dc),
      ];

  /// The flags watched by [posted].
  Set<int> watched(Iterable<int> posted) => {for (final p in posted) ...watch(p)};

  /// The flags no one watches.
  List<int> unwatched(Iterable<int> posted) {
    final w = watched(posted);
    return [for (var c = 0; c < flags; c++) if (!w.contains(c)) c];
  }

  /// Whether [posted] are [count] strong and watch every flag.
  bool lands(Iterable<int> posted, int count) => posted.length == count && unwatched(posted).isEmpty;

  /// The walk: every posting of [count] watchmen that watches the yard,
  /// found by posting a watchman on some flag that watches the first
  /// unwatched flag; when a later candidate is taken, the earlier ones
  /// are barred from then on, so every posting is told once, by the
  /// first of its watchmen that watches each flag in turn; how many
  /// there are.
  int walk(int count) {
    final cover = List.filled(flags, 0);
    final barred = List.filled(flags, 0);
    var found = 0;
    void go(int placed) {
      var first = -1;
      for (var c = 0; c < flags; c++) {
        if (cover[c] == 0) {
          first = c;
          break;
        }
      }
      if (first == -1) {
        if (placed == count) found++;
        return;
      }
      if (placed == count) return;
      final choices = [for (final p in watch(first)) if (barred[p] == 0) p];
      for (var i = 0; i < choices.length; i++) {
        final p = choices[i];
        for (final x in watch(p)) {
          cover[x]++;
        }
        for (var j = 0; j < i; j++) {
          barred[choices[j]]++;
        }
        go(placed + 1);
        for (var j = 0; j < i; j++) {
          barred[choices[j]]--;
        }
        for (final x in watch(p)) {
          cover[x]--;
        }
      }
    }

    go(0);
    return found;
  }

  /// The sweep, taken whole: every one of the choose(flags, count)
  /// postings held up in turn, no dropping, and (watching, all)
  /// counted. For the small yards, where that is bearable.
  (int, int) sweep(int count) {
    var watching = 0, all = 0;
    final chosen = <int>[];
    void go(int from, int left) {
      if (left == 0) {
        all++;
        if (unwatched(chosen).isEmpty) watching++;
        return;
      }
      for (var c = from; c <= flags - left; c++) {
        chosen.add(c);
        go(c + 1, left - 1);
        chosen.removeLast();
      }
    }

    go(0, count);
    return (watching, all);
  }

  /// choose(flags, count): every posting, told without the sweep.
  int postings(int count) => choose(flags, count);

  static int choose(int n, int k) {
    if (k < 0 || k > n) return 0;
    var out = 1;
    for (var i = 1; i <= k; i++) {
      out = out * (n - k + i) ~/ i;
    }
    return out;
  }

  /// The far flags: those in the rows and columns that are multiples of
  /// three, no two within one watchman's watch, so each wants a
  /// watchman of its own.
  List<int> get far => [
        for (var r = 0; r < size; r += 3)
          for (var c = 0; c < size; c += 3) at(r, c),
      ];

  /// The fewest watchmen that can watch the yard, by the far flags:
  /// one apiece.
  int get bound => far.length;

  /// The posting that watches the yard with that many: a watchman one
  /// in from each far flag, or on the last row or column when the yard
  /// runs out.
  List<int> get posting => [
        for (var r = 0; r < size; r += 3)
          for (var c = 0; c < size; c += 3) at(r + 1 < size ? r + 1 : size - 1, c + 1 < size ? c + 1 : size - 1),
      ];
}
