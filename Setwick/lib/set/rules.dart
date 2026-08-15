/// The law of the set.
///
/// Dancers numbered 1 to n - 1 stand in a ring, and the caller's
/// number is n. Two dancers partner when their numbers multiplied
/// come to one over n, that is, leave one when divided by n.
/// Dancer 1 and dancer n - 1 keep to themselves, since each comes
/// to one with itself; the rest must pair off. Wilson's theorem,
/// 1770, is what happens when they can: with n prime every dancer
/// from 2 to n - 2 has exactly one partner, so the whole set
/// multiplied together comes to n - 1 over n, which is to say
/// (n - 1)! + 1 divides by n. With n not prime some dancer shares
/// a factor with n and multiplies to nothing but that factor's
/// multiples, never to one, and the set never pairs off.
class Rules {
  Rules(this.caller);

  /// The caller's number: the modulus.
  final int caller;

  /// The dancers who must pair: 2 to n - 2.
  List<int> get dancers => [for (var d = 2; d <= caller - 2; d++) d];

  /// Whether two dancers come to one.
  bool comesToOne(int a, int b) => (a * b) % caller == 1;

  /// The one partner of a dancer, by Bezout's arithmetic and no
  /// searching: the extended Euclid walk on the dancer and the
  /// caller's number. Null when they share a factor.
  int? partnerOf(int dancer) {
    var oldR = dancer, r = caller;
    var oldS = 1, s = 0;
    while (r != 0) {
      final q = oldR ~/ r;
      (oldR, r) = (r, oldR - q * r);
      (oldS, s) = (s, oldS - q * s);
    }
    if (oldR != 1) return null;
    return ((oldS % caller) + caller) % caller;
  }

  /// The multiples of a dancer over the caller: what the dancer
  /// comes to with every other dancer, in order.
  List<int> row(int dancer) =>
      [for (var k = 1; k < caller; k++) (dancer * k) % caller];

  /// Whether a pairing lands: every dancer from 2 to n - 2 paired,
  /// and every pair coming to one.
  bool lands(Map<int, int> pairs) {
    for (final dancer in dancers) {
      final partner = pairs[dancer];
      if (partner == null || !comesToOne(dancer, partner)) return false;
    }
    return true;
  }

  /// Walks every way of pairing the dancers off, two by two, and
  /// calls [visit] with each as a map both ways.
  void pairings(void Function(Map<int, int>) visit) {
    final free = dancers;
    final pairs = <int, int>{};
    void pairOff() {
      int? first;
      for (final dancer in free) {
        if (!pairs.containsKey(dancer)) {
          first = dancer;
          break;
        }
      }
      if (first == null) {
        visit(pairs);
        return;
      }
      for (final other in free) {
        if (other <= first || pairs.containsKey(other)) continue;
        pairs[first] = other;
        pairs[other] = first;
        pairOff();
        pairs.remove(first);
        pairs.remove(other);
      }
    }

    pairOff();
  }

  /// How many pairings there are, and how many land, by the sweep.
  (int, int) sweep() {
    var all = 0, landed = 0;
    pairings((pairs) {
      all++;
      if (lands(pairs)) landed++;
    });
    return (all, landed);
  }

  /// The pairing Bezout gives, or null when some dancer has no
  /// partner: the same map the sweep lands on.
  Map<int, int>? landing() {
    final pairs = <int, int>{};
    for (final dancer in dancers) {
      final partner = partnerOf(dancer);
      if (partner == null || partner == dancer || partner < 2 || partner > caller - 2) {
        return null;
      }
      pairs[dancer] = partner;
    }
    return pairs;
  }

  /// (n - 1)! over n, computed whole: n - 1 for a prime, by
  /// Wilson, and nought for every composite past four.
  static int factorialOver(int n) {
    var product = BigInt.one;
    for (var k = 2; k < n; k++) {
      product = product * BigInt.from(k) % BigInt.from(n);
    }
    return product.toInt();
  }

  /// (n - 1)! itself, for the ledger.
  static BigInt factorial(int n) {
    var product = BigInt.one;
    for (var k = 2; k < n; k++) {
      product *= BigInt.from(k);
    }
    return product;
  }

  static bool isPrime(int n) {
    if (n < 2) return false;
    for (var d = 2; d * d <= n; d++) {
      if (n % d == 0) return false;
    }
    return true;
  }
}
