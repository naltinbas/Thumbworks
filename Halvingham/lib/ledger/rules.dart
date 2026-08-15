/// The law of the ledger: the first number is halved row by row, the
/// remainder dropped, until it comes to one, and the second is doubled
/// beside it; keep the doubles beside the odd halves and they add to
/// the product, since the odd halves are exactly the twos the first
/// number is made of.
class Rules {
  const Rules(this.first, this.second);

  final int first;
  final int second;

  int get product => first * second;

  /// The rows: (half, double), the first row the numbers themselves.
  List<(int, int)> get rows {
    final out = <(int, int)>[];
    var a = first, b = second;
    while (true) {
      out.add((a, b));
      if (a == 1) break;
      a ~/= 2;
      b *= 2;
    }
    return out;
  }

  /// The rows whose half is odd: the rule's keeping.
  List<int> get oddRows => [
        for (var i = 0; i < rows.length; i++)
          if (rows[i].$1.isOdd) i,
      ];

  /// What the doubles at [kept] rows add to.
  int sumOf(Iterable<int> kept) => kept.fold(0, (s, i) => s + rows[i].$2);

  /// Whether [kept] lands: the doubles add to the product, and the rows
  /// kept number [exactly] when that is asked.
  bool lands(Iterable<int> kept, {int? exactly}) =>
      sumOf(kept) == product && (exactly == null || kept.length == exactly);

  /// Every keeping of the rows swept, or every keeping of [exactly] rows:
  /// (landing, all).
  (int, int) sweep({int? exactly}) {
    final n = rows.length;
    var landing = 0, all = 0;
    for (var mask = 0; mask < (1 << n); mask++) {
      final kept = [for (var i = 0; i < n; i++) if ((mask >> i) & 1 == 1) i];
      if (exactly != null && kept.length != exactly) continue;
      all++;
      if (sumOf(kept) == product) landing++;
    }
    return (landing, all);
  }
}
