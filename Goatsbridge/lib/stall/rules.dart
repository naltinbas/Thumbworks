/// The law of the stall: n doors, a cart behind one and goats behind
/// the rest, all doors equally likely; the player picks a door; the host,
/// who knows where the cart is, opens k of the other doors that hide
/// goats, k at most n - 2, choosing among the goat doors he may open
/// equally; then the player stays or switches to one of the other unopened
/// doors, choosing equally. Staying wins when the first pick was right,
/// one in n; switching wins when it was wrong and the switch lands on the
/// cart, (n - 1)/n times 1/(n - 1 - k). Every fraction is exact.
class Rules {
  /// The doors the sham allows, and the least the host may open.
  static const doorsLeast = 3;
  static const doorsMost = 10;

  /// A fraction, lowest terms.
  static (int, int) fraction(int num, int den) {
    final g = _gcd(num.abs(), den.abs());
    return (num ~/ g, den ~/ g);
  }

  static int _gcd(int a, int b) => b == 0 ? a : _gcd(b, a % b);

  /// The chance of winning by the formula: staying 1/n, switching
  /// (n - 1)/(n(n - 1 - k)).
  static (int, int) byFormula(int doors, int opened, bool switching) {
    if (!switching) return fraction(1, doors);
    return fraction(doors - 1, doors * (doors - 1 - opened));
  }

  /// The chance of winning by counting every case: the cart's door and
  /// the pick, each of n; the host's choice of k goat doors among those
  /// he may open, each equally; and the switch's landing among the other
  /// unopened doors, each equally. Weighed as exact fractions and summed.
  static (int, int) byCases(int doors, int opened, bool switching) {
    var num = 0, den = 1;
    void add(int a, int b) {
      // num/den += a/b
      num = num * b + a * den;
      den *= b;
      final (p, q) = fraction(num, den);
      num = p;
      den = q;
    }

    for (var cart = 0; cart < doors; cart++) {
      for (var pick = 0; pick < doors; pick++) {
        // Doors the host may open: not the pick, not the cart.
        final may = [for (var d = 0; d < doors; d++) if (d != pick && d != cart) d];
        final subsets = _choose(may, opened);
        for (final open in subsets) {
          if (!switching) {
            if (cart == pick) add(1, doors * doors * subsets.length);
            continue;
          }
          final targets = [for (var d = 0; d < doors; d++) if (d != pick && !open.contains(d)) d];
          for (final t in targets) {
            if (t == cart) add(1, doors * doors * subsets.length * targets.length);
          }
        }
      }
    }
    return fraction(num, den);
  }

  static List<List<int>> _choose(List<int> from, int k) {
    if (k == 0) return [[]];
    if (from.length < k) return [];
    final out = <List<int>>[];
    for (var i = 0; i < from.length; i++) {
      for (final rest in _choose(from.sublist(i + 1), k - 1)) {
        out.add([from[i], ...rest]);
      }
    }
    return out;
  }

  /// Every setting of the sham: doors three to ten, the host opening one
  /// to n - 2, and stay or switch; asked, and how many meet the ask,
  /// with the count of settings.
  static (int, int) sweep(bool Function(int doors, int opened, bool switching) ask) {
    var met = 0, all = 0;
    for (var n = doorsLeast; n <= doorsMost; n++) {
      for (var k = 1; k <= n - 2; k++) {
        for (final sw in [false, true]) {
          all++;
          if (ask(n, k, sw)) met++;
        }
      }
    }
    return (met, all);
  }

  /// The first setting meeting [ask], or null.
  static (int, int, bool)? first(bool Function(int doors, int opened, bool switching) ask) {
    for (var n = doorsLeast; n <= doorsMost; n++) {
      for (var k = 1; k <= n - 2; k++) {
        for (final sw in [false, true]) {
          if (ask(n, k, sw)) return (n, k, sw);
        }
      }
    }
    return null;
  }

  /// Compares two fractions: negative, nought or positive.
  static int compare((int, int) a, (int, int) b) => (a.$1 * b.$2 - b.$1 * a.$2).sign;

  /// A fraction as words in a hundred, to two places, cut.
  static String inHundred((int, int) f) {
    final scaled = f.$1 * 10000 ~/ f.$2;
    return '${scaled ~/ 100}.${(scaled % 100).toString().padLeft(2, '0')}';
  }
}
