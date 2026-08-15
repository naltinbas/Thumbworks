/// The arithmetic of the watch: queens on an n by n board, each seeing
/// her own square and every square along her row, her column and her
/// two slants, and how many queens it takes to see every square. Two
/// voices: the sweep, every placing of the count tried as masks of
/// squares seen; and the picking, queens set to see the first unseen
/// square in turn, which finds every set that watches the board and no
/// other, counted with no overlap by keeping the queens in order.
class Rules {
  /// The squares queen at [i] sees on a [side] board, as a bit mask
  /// (side at most 8, so 64 bits at most).
  static int seenFrom(int side, int i) {
    final r = i ~/ side, c = i % side;
    var mask = 0;
    for (var s = 0; s < side * side; s++) {
      final sr = s ~/ side, sc = s % side;
      if (sr == r || sc == c || (sr - sc) == (r - c) || (sr + sc) == (r + c)) mask |= 1 << s;
    }
    return mask;
  }

  /// The masks of every square of a board, kept once per side.
  static final _masks = <int, List<int>>{};

  static List<int> masks(int side) => _masks.putIfAbsent(side, () => [for (var i = 0; i < side * side; i++) seenFrom(side, i)]);

  static int all(int side) => side * side == 64 ? -1 : (1 << (side * side)) - 1;

  /// The squares seen by the queens at [squares], as a mask.
  static int seen(int side, List<int> squares) {
    var mask = 0;
    for (final q in squares) {
      mask |= masks(side)[q];
    }
    return mask;
  }

  /// How many squares the queens leave unseen.
  static int unseen(int side, List<int> squares) {
    final m = seen(side, squares) & all(side);
    var n = 0;
    for (var s = 0; s < side * side; s++) {
      if (m & (1 << s) == 0) n++;
    }
    return n;
  }

  /// Whether the queens watch the whole board.
  static bool watches(int side, List<int> squares) => (seen(side, squares) & all(side)) == all(side);

  /// The sweep: how many placings of [count] queens on the board watch
  /// it, and the fewest squares any placing leaves unseen; every
  /// combination tried in order.
  static (int, int) sweep(int side, int count) {
    final n = side * side, ms = masks(side), whole = all(side);
    var watching = 0, fewestUnseen = n;
    final pick = List<int>.filled(count, 0);
    void go(int k, int from, int mask) {
      if (k == count) {
        final m = mask & whole;
        if (m == whole) {
          watching++;
          fewestUnseen = 0;
        } else if (fewestUnseen > 0) {
          var u = 0;
          for (var s = 0; s < n; s++) {
            if (m & (1 << s) == 0) u++;
          }
          if (u < fewestUnseen) fewestUnseen = u;
        }
        return;
      }
      for (var i = from; i <= n - (count - k); i++) {
        pick[k] = i;
        go(k + 1, i + 1, mask | ms[i]);
      }
    }

    go(0, 0, 0);
    return (watching, fewestUnseen);
  }

  /// The picking: sets of [count] queens that watch the board, found by
  /// setting a queen to see the first unseen square each time, every
  /// square that sees it tried in turn; a set may be found by more than
  /// one order of picking, so the sets are kept as sorted keys and
  /// counted once each. Returns the count and the first set found.
  static (int, List<int>?) picking(int side, int count) {
    final n = side * side, ms = masks(side), whole = all(side);
    final found = <String>{};
    List<int>? first;
    final set = <int>[];
    void go(int mask) {
      final m = mask & whole;
      if (m == whole) {
        final sorted = List.of(set)..sort();
        if (found.add(sorted.join(','))) first ??= sorted;
        return;
      }
      if (set.length == count) return;
      var bare = 0;
      while (m & (1 << bare) != 0) {
        bare++;
      }
      for (var q = 0; q < n; q++) {
        if (ms[q] & (1 << bare) == 0 || set.contains(q)) continue;
        set.add(q);
        go(mask | ms[q]);
        set.removeLast();
      }
    }

    go(0);
    return (found.length, first);
  }

  /// The sweep once more, counting the placings of [count] queens that
  /// leave exactly [unseenAsked] squares unseen.
  static int sweepUnseen(int side, int count, int unseenAsked) {
    final n = side * side, ms = masks(side), whole = all(side);
    var hits = 0;
    void go(int k, int from, int mask) {
      if (k == count) {
        final m = mask & whole;
        var u = 0;
        for (var s = 0; s < n; s++) {
          if (m & (1 << s) == 0) u++;
        }
        if (u == unseenAsked) hits++;
        return;
      }
      for (var i = from; i <= n - (count - k); i++) {
        go(k + 1, i + 1, mask | ms[i]);
      }
    }

    go(0, 0, 0);
    return hits;
  }

  /// The most squares one queen sees on a [side] board, and where.
  static (int, int) mostSeen(int side) {
    var most = 0, at = 0;
    for (var i = 0; i < side * side; i++) {
      var n = 0;
      final m = masks(side)[i];
      for (var s = 0; s < side * side; s++) {
        if (m & (1 << s) != 0) n++;
      }
      if (n > most) {
        most = n;
        at = i;
      }
    }
    return (most, at);
  }

  /// A square told: 'c3'.
  static String told(int side, int i) => '${'abcdefgh'[i % side]}${side - i ~/ side}';
}
