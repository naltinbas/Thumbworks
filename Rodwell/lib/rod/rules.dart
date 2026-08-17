/// A rod marked off in hands, to be cut into whole parts. The parts are
/// multiplied together and the ask is to make that product as big as it
/// will go.
///
/// The answer is always threes. A part of five or more can be cut into
/// a three and the rest and the product goes up, since 3(n - 3) beats n
/// once n is five or more; a four can be left or cut into two twos, and
/// they come to the same; and three twos should be two threes, since 9
/// beats 8. So the best cutting is all threes when the rod divides by
/// three, all threes and a four when one is left over, and all threes
/// and a two when two are.
///
/// This is the whole-number face of the old rule that a fixed sum is
/// multiplied best by equal parts, with e as the size the parts would
/// take if they could be any length at all. Three is the whole number
/// nearest it.
class Rules {
  /// The rods the game uses, in hands.
  static const shortest = 2, longest = 20;

  /// Every place a cut can go on a rod of [hands]: after the first
  /// hand, after the second, and so on.
  static int places(int hands) => hands - 1;

  /// The parts a cutting leaves, in order along the rod. A cut at
  /// place i means the rod is severed after hand i + 1.
  static List<int> partsOf(int hands, Set<int> cuts) {
    final parts = <int>[];
    var run = 0;
    for (var hand = 0; hand < hands; hand++) {
      run++;
      if (cuts.contains(hand) && hand < hands - 1) {
        parts.add(run);
        run = 0;
      }
    }
    parts.add(run);
    return parts;
  }

  /// What the parts multiply to.
  static BigInt product(List<int> parts) {
    var out = BigInt.one;
    for (final part in parts) {
      out *= BigInt.from(part);
    }
    return out;
  }

  /// The biggest product a rod of [hands] can be cut to, by trying
  /// every cutting there is: the first voice.
  static BigInt bestBySweep(int hands) {
    var best = BigInt.zero;
    for (final cuts in cuttings(hands)) {
      final got = product(partsOf(hands, cuts));
      if (got > best) best = got;
    }
    return best;
  }

  /// The same by the rule of threes, which cuts nothing: the second
  /// voice.
  static BigInt bestByRule(int hands) {
    if (hands <= 4) return BigInt.from(hands);
    final threes = hands ~/ 3, left = hands % 3;
    final three = BigInt.from(3);
    switch (left) {
      case 0:
        return three.pow(threes);
      case 1:
        return three.pow(threes - 1) * BigInt.from(4);
      default:
        return three.pow(threes) * BigInt.two;
    }
  }

  /// The same again by working up from the short rods, each one cut
  /// once and the rest looked up: the third voice.
  static List<BigInt> bestByWorkingUp(int longest) {
    final best = <BigInt>[BigInt.zero, BigInt.one];
    for (var hands = 2; hands <= longest; hands++) {
      var top = BigInt.from(hands);
      for (var first = 1; first < hands; first++) {
        final got = BigInt.from(first) * best[hands - first];
        if (got > top) top = got;
      }
      best.add(top);
    }
    return best;
  }

  /// The parts of the best cutting by the rule, longest part last.
  static List<int> bestParts(int hands) {
    if (hands <= 4) return [hands];
    final left = hands % 3;
    final threes = left == 1 ? hands ~/ 3 - 1 : hands ~/ 3;
    return [
      for (var i = 0; i < threes; i++) 3,
      if (left == 1) 4,
      if (left == 2) 2,
    ]..sort();
  }

  /// Every way a rod of [hands] can be cut.
  static Iterable<Set<int>> cuttings(int hands) sync* {
    final spots = places(hands);
    for (var mask = 0; mask < (1 << spots); mask++) {
      yield {
        for (var spot = 0; spot < spots; spot++)
          if (mask >> spot & 1 == 1) spot,
      };
    }
  }

  static int howManyCuttings(int hands) => 1 << places(hands);

  /// How many cuttings of a rod of [hands] reach [product].
  static int cuttingsAt(int hands, BigInt want) {
    var count = 0;
    for (final cuts in cuttings(hands)) {
      if (product(partsOf(hands, cuts)) == want) count++;
    }
    return count;
  }

  /// The cutting the pointer works towards: the parts of the best
  /// cutting laid along the rod, biggest part first, which is the
  /// fewest cuts that reach the best.
  static Set<int> bestCuts(int hands) {
    final parts = bestParts(hands).reversed.toList();
    final cuts = <int>{};
    var at = 0;
    for (var i = 0; i < parts.length - 1; i++) {
      at += parts[i];
      cuts.add(at - 1);
    }
    return cuts;
  }

  static String tellParts(List<int> parts) => parts.join(' + ');

  static String tellProduct(BigInt product) {
    final digits = product.toString();
    final out = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) out.write(',');
      out.write(digits[i]);
    }
    return out.toString();
  }
}
