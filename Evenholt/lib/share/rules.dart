/// The law of the share.
///
/// Tokens numbered 1 to n, shared between two trays half and
/// half, so that the sums of the two trays agree, then the sums
/// of squares, then of cubes, as far as the share asks. Prouhet
/// showed in 1851 that 2^k tokens can be shared so that every
/// power up to k - 1 agrees, by the doubling pattern Thue and
/// Morse later made their own: token 1 goes left, and so does
/// every token whose number less one has an even count of ones
/// when written in twos. The sweep here finds that pattern is
/// the only share of eight that squares and the only share of
/// sixteen that cubes, that a dozen squares one way with no
/// doubling behind it, and that four tokens never square at all.
class Rules {
  Rules(this.count, this.degrees);

  /// How many tokens, 1 to [count].
  final int count;

  /// How many powers must agree: 1 for sums, 2 for squares too,
  /// 3 for cubes as well.
  final int degrees;

  int get half => count ~/ 2;

  /// The sum of the [degree]-th powers of the tokens on one side.
  int powerSum(List<bool> right, {required bool side, required int degree}) {
    var total = 0;
    for (var token = 1; token <= count; token++) {
      if (right[token - 1] != side) continue;
      var power = 1;
      for (var times = 0; times < degree; times++) {
        power *= token;
      }
      total += power;
    }
    return total;
  }

  int onSide(List<bool> right, bool side) =>
      right.where((r) => r == side).length;

  /// Whether a share lands: half and half, and every asked power
  /// agreeing.
  bool lands(List<bool> right) {
    if (onSide(right, true) != half) return false;
    for (var degree = 1; degree <= degrees; degree++) {
      if (powerSum(right, side: false, degree: degree) !=
          powerSum(right, side: true, degree: degree)) {
        return false;
      }
    }
    return true;
  }

  /// The powers agreeing so far, degree by degree.
  List<bool> agreeing(List<bool> right) => [
        for (var degree = 1; degree <= degrees; degree++)
          powerSum(right, side: false, degree: degree) ==
              powerSum(right, side: true, degree: degree),
      ];

  /// Walks every half-and-half share with token 1 on the left,
  /// so each unordered share is seen once; calls [visit] with
  /// each.
  void shares(void Function(List<bool>) visit) {
    final right = List.filled(count, false);
    void place(int token, int placedRight) {
      if (placedRight > half) return;
      if (token > count) {
        if (placedRight == half) visit(right);
        return;
      }
      if (token == 1) {
        place(2, 0);
        return;
      }
      right[token - 1] = false;
      place(token + 1, placedRight);
      right[token - 1] = true;
      place(token + 1, placedRight + 1);
      right[token - 1] = false;
    }

    place(1, 0);
  }

  /// How many shares land, by the sweep.
  int waysBySweep() {
    var ways = 0;
    shares((right) {
      if (lands(right)) ways++;
    });
    return ways;
  }

  /// The first landing share the sweep finds, token 1 left, or
  /// null.
  List<bool>? landing() {
    List<bool>? found;
    shares((right) {
      if (found == null && lands(right)) found = List.of(right);
    });
    return found;
  }

  /// Prouhet's share, by the doubling pattern: token t goes right
  /// when t - 1 has an odd count of ones written in twos. Only
  /// for a count that is a power of two; null otherwise.
  List<bool>? prouhet() {
    if (count < 2 || (count & (count - 1)) != 0) return null;
    return [
      for (var token = 1; token <= count; token++)
        _ones(token - 1).isOdd,
    ];
  }

  int _ones(int n) {
    var ones = 0;
    var left = n;
    while (left > 0) {
      ones += left & 1;
      left >>= 1;
    }
    return ones;
  }

  /// The doublings behind a power-of-two count: 2 for four, 3
  /// for eight, 4 for sixteen.
  int get doublings {
    var k = 0;
    var n = count;
    while (n > 1) {
      n ~/= 2;
      k++;
    }
    return k;
  }

  /// Prouhet's polynomial, the product of (1 - x^(2^i)) over the
  /// doublings: its coefficients are the sides of his share, +1
  /// left and -1 right, token by token from x^0.
  List<int> prouhetPolynomial() {
    var poly = [1];
    for (var i = 0; i < doublings; i++) {
      final step = 1 << i;
      final factor = List.filled(step + 1, 0);
      factor[0] = 1;
      factor[step] = -1;
      final next = List.filled(poly.length + step, 0);
      for (var a = 0; a < poly.length; a++) {
        for (var b = 0; b < factor.length; b++) {
          next[a + b] += poly[a] * factor[b];
        }
      }
      poly = next;
    }
    return poly;
  }

  /// How many times (1 - x) divides a polynomial exactly: the
  /// multiplicity of its root at one.
  static int rootAtOne(List<int> poly) {
    var times = 0;
    var current = List.of(poly);
    while (current.length > 1) {
      // (1 - x) q = p: q0 = p0, qi = pi + q(i-1), and the last
      // coefficient must cancel.
      final quotient = <int>[];
      for (var i = 0; i < current.length - 1; i++) {
        quotient.add(current[i] + (quotient.isEmpty ? 0 : quotient.last));
      }
      if (current.last + quotient.last != 0) break;
      times++;
      current = quotient;
    }
    return times;
  }
}
