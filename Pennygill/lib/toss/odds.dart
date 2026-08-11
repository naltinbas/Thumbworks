import 'call.dart';

/// A ratio of whole numbers, kept exact.
class Ratio {
  const Ratio(this.top, this.bottom);

  final BigInt top;
  final BigInt bottom;

  static Ratio of(int top, int bottom) =>
      Ratio(BigInt.from(top), BigInt.from(bottom));

  Ratio get eased {
    final common = top.gcd(bottom);
    if (common == BigInt.one) return this;
    return Ratio(top ~/ common, bottom ~/ common);
  }

  double get asDouble => top / bottom;

  @override
  bool operator ==(Object other) {
    if (other is! Ratio) return false;
    return top * other.bottom == other.top * bottom;
  }

  @override
  int get hashCode => eased.top.hashCode ^ eased.bottom.hashCode;

  @override
  String toString() {
    final tidy = eased;
    return '${tidy.top} in ${tidy.bottom}';
  }
}

/// The chance one call comes up before another, worked out two ways that
/// share nothing.
///
/// Conway's way is the strange one: for calls A and B, count how the tail
/// ends of A lie over the front ends of B, reading the overlaps as a
/// binary number, and the odds fall out of four such counts. It looks like
/// numerology and it is exact.
///
/// The long way is a walk through every state the flipping can be in: how
/// much of each call the last flips have built. The states form a little
/// chain with two exits, the exit chances obey plain linear equations, and
/// the equations are solved exactly in whole-number ratios. The anchor
/// test lays the two over each other on every pair of calls there is.
class Odds {
  const Odds._();

  /// Conway's leading number: for each length k from three down to one,
  /// does the last k of [one] equal the first k of [other]? Read the
  /// yes-noes as binary, longest overlap first.
  static int leading(Call one, Call other) {
    var read = 0;
    for (var k = 3; k >= 1; k--) {
      final tail = one.flips & ((1 << k) - 1);
      final front = other.flips >> (3 - k);
      read = read * 2 + (tail == front ? 1 : 0);
    }
    return read;
  }

  /// The chance [other] comes up before [one], by Conway's counts.
  static Ratio byConway(Call one, Call other) {
    final top = leading(one, one) - leading(one, other);
    final bottom = leading(other, other) - leading(other, one);
    return Ratio.of(top, top + bottom);
  }

  /// The chance [other] comes up before [one], by the long way: exact
  /// linear equations over the states of the flipping.
  ///
  /// A state is what the recent flips have built: the longest tail of the
  /// flips that is a front of one call or the other, tracked for both at
  /// once by remembering the last two flips (or fewer, early on). From
  /// each state a head or a tail moves to another state or ends the game;
  /// chance of [other] winning from each state obeys
  /// p(s) = (p(s after H) + p(s after T)) / 2, and the empty start is the
  /// answer. Solved by elimination over exact ratios.
  static Ratio byWalk(Call one, Call other) {
    // States: runs of recent flips of length 0, 1 or 2 that could still
    // grow into either call: there are seven, '' plus H T HH HT TH TT.
    const runs = ['', 'H', 'T', 'HH', 'HT', 'TH', 'TT'];

    // For each state and each next flip, where do we land? Build the flip
    // history's meaningful suffix by hand: append, check for a finished
    // call, else keep the longest suffix of length two.
    (int, int)? land(int state, bool heads) {
      final grown = runs[state] + (heads ? 'H' : 'T');
      if (grown.length == 3) {
        if (grown == one.said) return null; // one wins: chance nought.
        if (grown == other.said) return (-1, 0); // other wins outright.
      }
      final keep = grown.length <= 2
          ? grown
          : grown.substring(grown.length - 2);
      return (runs.indexOf(keep), 0);
    }

    // p(s) = half p(next H) + half p(next T), with wins at the exits.
    // Gaussian elimination over ratios, seven unknowns, tiny and exact.
    final rows = List.generate(
      runs.length,
      (state) => List<Ratio>.filled(runs.length + 1, Ratio.of(0, 1)),
    );
    for (var state = 0; state < runs.length; state++) {
      rows[state][state] = Ratio.of(1, 1);
      for (final heads in const [true, false]) {
        final landed = land(state, heads);
        if (landed == null) continue;
        if (landed.$1 == -1) {
          rows[state][runs.length] =
              _add(rows[state][runs.length], Ratio.of(1, 2));
        } else {
          rows[state][landed.$1] =
              _add(rows[state][landed.$1], Ratio.of(-1, 2));
        }
      }
    }

    for (var lead = 0; lead < runs.length; lead++) {
      var tall = lead;
      while (rows[tall][lead].top == BigInt.zero) {
        tall++;
      }
      final swap = rows[lead];
      rows[lead] = rows[tall];
      rows[tall] = swap;
      for (var row = 0; row < runs.length; row++) {
        if (row == lead || rows[row][lead].top == BigInt.zero) continue;
        final times = _over(rows[row][lead], rows[lead][lead]);
        for (var col = lead; col <= runs.length; col++) {
          rows[row][col] =
              _add(rows[row][col], _minus(_times(times, rows[lead][col])));
        }
      }
    }
    return _over(rows[0][runs.length], rows[0][0]).eased;
  }

  static Ratio _add(Ratio a, Ratio b) =>
      Ratio(a.top * b.bottom + b.top * a.bottom, a.bottom * b.bottom);
  static Ratio _minus(Ratio a) => Ratio(-a.top, a.bottom);
  static Ratio _times(Ratio a, Ratio b) =>
      Ratio(a.top * b.top, a.bottom * b.bottom);
  static Ratio _over(Ratio a, Ratio b) =>
      Ratio(a.top * b.bottom, a.bottom * b.top);
}
