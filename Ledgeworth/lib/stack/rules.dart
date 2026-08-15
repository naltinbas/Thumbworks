/// The law of the leaning stack: books a book long, each resting on
/// the one below and the lowest on the desk, every edge measured in
/// twenty-fourths of a book past the edge below it.
class Rules {
  /// Twenty-fourths to a book.
  static const grain = 24;

  /// The right edge of each book, top first, past the desk's edge:
  /// the running sum of the offsets from the bottom up.
  static List<int> edges(List<int> offsets) {
    final n = offsets.length;
    final out = List.filled(n, 0);
    var edge = 0;
    for (var i = n - 1; i >= 0; i--) {
      edge += offsets[i];
      out[i] = edge;
    }
    return out;
  }

  /// The overhang: the top book's right edge past the desk.
  static int overhang(List<int> offsets) => offsets.fold(0, (a, b) => a + b);

  /// The first level that topples, counting from the top: the books
  /// above it have their weight past the edge they rest on. Null when
  /// the stack stands. Level k means books 1..k rest on book k + 1,
  /// or on the desk when k is the count.
  static int? topples(List<int> offsets) {
    final n = offsets.length;
    final e = edges(offsets);
    var centres = 0; // twice the sum of centres, in twenty-fourths, times... kept exact below
    // The centre of book i is its edge less half a book; the mean of
    // k centres must not pass the edge below. Compare k times the
    // edge below with the sum of centres, all in twenty-fourths.
    for (var k = 1; k <= n; k++) {
      centres += e[k - 1] - grain ~/ 2;
      final below = k < n ? e[k] : 0;
      if (centres > k * below) return k;
    }
    return null;
  }

  static bool stands(List<int> offsets) => topples(offsets) == null;

  /// The harmonic stack on the grid: the top book out half, the next
  /// a quarter, then a sixth, an eighth, a tenth, each rounded down
  /// to the twenty-fourth.
  static List<int> harmonic(int books) => [for (var k = 1; k <= books; k++) grain ~/ (2 * k)];

  /// The harmonic overhang exactly, as a fraction of a book: half of
  /// 1 + 1/2 + ... + 1/n, numerator over denominator in lowest terms.
  static (int, int) harmonicOverhang(int books) {
    var num = 0, den = 1;
    for (var k = 1; k <= books; k++) {
      // add 1/(2k)
      num = num * 2 * k + den;
      den = den * 2 * k;
      final g = _gcd(num, den);
      num ~/= g;
      den ~/= g;
    }
    return (num, den);
  }

  static int _gcd(int a, int b) => b == 0 ? a : _gcd(b, a % b);

  /// The sweep: every stack of [books] on the grid, offsets nought to a
  /// whole book each, and how many stand with the overhang asked or
  /// more; and the best overhang any standing stack reaches.
  static (int ways, int all, int best) sweep(int books, int asked) {
    var ways = 0, all = 0, best = 0;
    final offsets = List.filled(books, 0);
    void grow(int i) {
      if (i == books) {
        all++;
        if (stands(offsets)) {
          final o = overhang(offsets);
          if (o > best) best = o;
          if (o >= asked) ways++;
        }
        return;
      }
      for (var v = 0; v <= grain; v++) {
        offsets[i] = v;
        grow(i + 1);
      }
    }

    grow(0);
    return (ways, all, best);
  }
}
