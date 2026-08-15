/// The law of the count.
///
/// Eggs in a tray, and a count of them wanted that leaves so many
/// over when laid out by threes, so many by fives, so many by
/// sevens. Sun Tzu's problem, fourth century or so, and the
/// Chinese remainder theorem is its answer: when the row lengths
/// share no factor, every asking has exactly one count below their
/// product, built from Bezout's arithmetic with no searching; when
/// they do share one, an asking is met only if the leftovers agree
/// on it, and odd by fours never goes even by sixes.
class Rules {
  Rules(this.rows, {this.capacity = 30});

  /// The row lengths eggs are laid out by.
  final List<int> rows;

  /// How many eggs the tray holds.
  final int capacity;

  /// What a count leaves over by each row length.
  List<int> leftovers(int count) => [for (final row in rows) count % row];

  /// Whether a count meets an asking.
  bool meets(int count, List<int> asked) {
    for (var i = 0; i < rows.length; i++) {
      if (count % rows[i] != asked[i]) return false;
    }
    return true;
  }

  /// Every count in the tray, nought to the capacity, that meets
  /// an asking: the sweep.
  List<int> counts(List<int> asked) =>
      [for (var count = 0; count <= capacity; count++) if (meets(count, asked)) count];

  static int gcd(int a, int b) => b == 0 ? a : gcd(b, a % b);

  static int lcm(int a, int b) => a ~/ gcd(a, b) * b;

  /// The product of the row lengths' lowest common multiple: the
  /// span within which counts repeat.
  int get span => rows.fold(1, lcm);

  /// Whether the row lengths share no factor two by two.
  bool get coprime {
    for (var i = 0; i < rows.length; i++) {
      for (var j = i + 1; j < rows.length; j++) {
        if (gcd(rows[i], rows[j]) != 1) return false;
      }
    }
    return true;
  }

  /// Whether an asking can be met at all, by the arithmetic and no
  /// searching: the leftovers must agree on every shared factor,
  /// two rows at a time.
  bool meetable(List<int> asked) {
    for (var i = 0; i < rows.length; i++) {
      for (var j = i + 1; j < rows.length; j++) {
        final g = gcd(rows[i], rows[j]);
        if (asked[i] % g != asked[j] % g) return false;
      }
    }
    return true;
  }

  /// The count Sun Tzu's construction gives for coprime rows: for
  /// each row, the product of the others times its inverse over
  /// that row times the leftover, all added and taken over the
  /// span. Null when the rows share a factor.
  int? byConstruction(List<int> asked) {
    if (!coprime) return null;
    var total = 0;
    for (var i = 0; i < rows.length; i++) {
      final others = span ~/ rows[i];
      final inverse = _inverse(others % rows[i], rows[i]);
      total += asked[i] * others * inverse;
    }
    return total % span;
  }

  /// The inverse of a over m by Bezout's walk, for coprime a and m.
  static int _inverse(int a, int m) {
    var oldR = a % m, r = m;
    var oldS = 1, s = 0;
    while (r != 0) {
      final q = oldR ~/ r;
      (oldR, r) = (r, oldR - q * r);
      (oldS, s) = (s, oldS - q * s);
    }
    return ((oldS % m) + m) % m;
  }

  /// Every asking there is: every leftover for every row.
  void askings(void Function(List<int>) visit) {
    final asked = <int>[];
    void pick(int i) {
      if (i == rows.length) {
        visit(asked);
        return;
      }
      for (var left = 0; left < rows[i]; left++) {
        asked.add(left);
        pick(i + 1);
        asked.removeLast();
      }
    }

    pick(0);
  }
}
