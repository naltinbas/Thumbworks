/// The law of the moot: S seats shared among hamlets by population.
/// Hamilton's method gives each hamlet its quota, its population's share
/// of S, rounded down, and the seats left over go one each to the
/// hamlets whose quotas have the largest fractions. Jefferson's method
/// deals the seats one at a time, each to the hamlet whose population
/// per seat, counting the seat it would get, is largest, which comes to
/// the same as a common divisor with every quotient rounded down.
/// Hamilton's shares can fall when the moot grows by a seat, the Alabama
/// paradox of 1880; Jefferson's never can, since a seat once dealt is
/// never taken back. Every quota is an exact fraction.
class Rules {
  /// The moots the sham allows.
  static const least = 2;
  static const most = 30;

  /// The quotas of [pops] in a moot of [seats], as (numerator, total).
  static List<(int, int)> quotas(List<int> pops, int seats) {
    final total = pops.fold(0, (a, b) => a + b);
    return [for (final p in pops) (p * seats, total)];
  }

  /// Hamilton's shares: quotas rounded down, the seats left over to the
  /// largest fractions, ties to the larger population then the earlier
  /// hamlet.
  static List<int> hamilton(List<int> pops, int seats) {
    final total = pops.fold(0, (a, b) => a + b);
    final floors = [for (final p in pops) p * seats ~/ total];
    var left = seats - floors.fold(0, (a, b) => a + b);
    final order = List.generate(pops.length, (i) => i)
      ..sort((a, b) {
        // fraction a = (pa*S mod T)/T; compare numerators
        final fa = pops[a] * seats % total, fb = pops[b] * seats % total;
        if (fa != fb) return fb - fa;
        if (pops[a] != pops[b]) return pops[b] - pops[a];
        return a - b;
      });
    final out = List.of(floors);
    for (final i in order) {
      if (left == 0) break;
      out[i]++;
      left--;
    }
    return out;
  }

  /// Jefferson's shares dealt a seat at a time: each seat to the hamlet
  /// whose population over one more than its seats is largest, ties to
  /// the larger population then the earlier hamlet.
  static List<int> jeffersonDealt(List<int> pops, int seats) {
    final out = List.filled(pops.length, 0);
    for (var s = 0; s < seats; s++) {
      var best = 0;
      for (var i = 1; i < pops.length; i++) {
        // pops[i]/(out[i]+1) > pops[best]/(out[best]+1)
        final lhs = pops[i] * (out[best] + 1), rhs = pops[best] * (out[i] + 1);
        if (lhs > rhs || (lhs == rhs && pops[i] > pops[best])) best = i;
      }
      out[best]++;
    }
    return out;
  }

  /// Jefferson's shares by a divisor: the largest whole-number-friendly
  /// divisor is found by trying every candidate quotient p/k, and each
  /// hamlet gets its population over the divisor rounded down; where the
  /// divisor lands on a tie the tie goes as the dealing goes. Returned as
  /// the shares only, for holding against the dealing.
  static List<int> jeffersonByDivisor(List<int> pops, int seats) {
    // Candidate divisors are p/k for every hamlet and k; sort them and
    // find the largest at which floor sums reach seats.
    final candidates = <(int, int)>[];
    for (final p in pops) {
      for (var k = 1; k <= seats + 1; k++) {
        candidates.add((p, k));
      }
    }
    // Sort descending by p/k.
    candidates.sort((a, b) => (b.$1 * a.$2).compareTo(a.$1 * b.$2));
    // The divisor d = p/k: hamlet j gets floor(pj / d) = floor(pj * k / p).
    List<int> at((int, int) d) => [for (final pj in pops) pj * d.$2 ~/ d.$1];
    for (final d in candidates) {
      final shares = at(d);
      final sum = shares.fold(0, (a, b) => a + b);
      if (sum >= seats) {
        if (sum == seats) return shares;
        // Ties at this divisor: back off to the dealing for the shares.
        return jeffersonDealt(pops, seats);
      }
    }
    return jeffersonDealt(pops, seats);
  }

  /// Whether growing the moot from [seats] to seats + 1 costs some
  /// hamlet a seat under Hamilton: the Alabama paradox.
  static bool alabama(List<int> pops, int seats) {
    final now = hamilton(pops, seats), then = hamilton(pops, seats + 1);
    for (var i = 0; i < pops.length; i++) {
      if (then[i] < now[i]) return true;
    }
    return false;
  }

  /// The hamlet that loses a seat when the moot grows, or null.
  static int? loser(List<int> pops, int seats) {
    final now = hamilton(pops, seats), then = hamilton(pops, seats + 1);
    for (var i = 0; i < pops.length; i++) {
      if (then[i] < now[i]) return i;
    }
    return null;
  }

  /// Whether Jefferson gives some hamlet more than its quota rounded up.
  static bool overQuota(List<int> pops, int seats) {
    final j = jeffersonDealt(pops, seats);
    final total = pops.fold(0, (a, b) => a + b);
    for (var i = 0; i < pops.length; i++) {
      final ceil = (pops[i] * seats + total - 1) ~/ total;
      if (j[i] > ceil) return true;
    }
    return false;
  }

  /// Whether every quota is a whole number.
  static bool wholeQuotas(List<int> pops, int seats) {
    final total = pops.fold(0, (a, b) => a + b);
    return pops.every((p) => (p * seats) % total == 0);
  }

  /// Whether growing the moot costs a hamlet a seat under Jefferson.
  static bool jeffersonFalls(List<int> pops, int seats) {
    final now = jeffersonDealt(pops, seats), then = jeffersonDealt(pops, seats + 1);
    for (var i = 0; i < pops.length; i++) {
      if (then[i] < now[i]) return true;
    }
    return false;
  }

  /// Every moot on the sham, asked, and how many meet the ask, with the
  /// count of moots.
  static (int, int) sweep(bool Function(int seats) ask) {
    var met = 0, all = 0;
    for (var s = least; s <= most; s++) {
      all++;
      if (ask(s)) met++;
    }
    return (met, all);
  }

  /// The first moot meeting [ask], or null.
  static int? first(bool Function(int seats) ask) {
    for (var s = least; s <= most; s++) {
      if (ask(s)) return s;
    }
    return null;
  }

  /// A quota as words: '4 2/7'.
  static String quotaWords((int, int) q) {
    final (n, t) = q;
    final whole = n ~/ t, rest = n % t;
    if (rest == 0) return '$whole';
    final g = _gcd(rest, t);
    return whole == 0 ? '${rest ~/ g}/${t ~/ g}' : '$whole ${rest ~/ g}/${t ~/ g}';
  }

  static int _gcd(int a, int b) => b == 0 ? a : _gcd(b, a % b);
}
