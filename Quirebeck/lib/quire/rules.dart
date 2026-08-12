/// The law of the weave.
///
/// A quire is a stack of leaves, and a weave is the binder's perfect
/// shuffle: split the stack in half, then lay the two halves together
/// one leaf at a time. The out-weave starts with the top half and
/// keeps the first leaf first; the in-weave starts with the under
/// half and buries it.
///
/// Where a leaf can be sent is known two ways that share nothing: a
/// walk of every weaving, and plain figures. The shortest weaving
/// that carries the top leaf to a seat is the seat's own number
/// written in binary, an in for a one and an out for a nought; and
/// no weaving at all mends a single turned pair, because a weave is
/// an even number of swaps and one turned pair is odd. The suite
/// proves both against the walk.
class Rules {
  /// The out-weave: top half first, first leaf stays first.
  static List<int> weaveOut(List<int> quire) {
    final half = quire.length ~/ 2;
    return [
      for (var at = 0; at < half; at++) ...[
        quire[at],
        quire[half + at],
      ],
    ];
  }

  /// The in-weave: under half first, the top leaf goes under.
  static List<int> weaveIn(List<int> quire) {
    final half = quire.length ~/ 2;
    return [
      for (var at = 0; at < half; at++) ...[
        quire[half + at],
        quire[at],
      ],
    ];
  }

  static List<int> weave(List<int> quire, bool inward) =>
      inward ? weaveIn(quire) : weaveOut(quire);

  /// The seat's weaving, from the figures alone: the seat written in
  /// binary, read left to right, true for an in. Seat nought needs
  /// nothing.
  static List<bool> seatWord(int seat) {
    if (seat == 0) return const [];
    final word = <bool>[];
    for (var bit = seat.bitLength - 1; bit >= 0; bit--) {
      word.add((seat >> bit) & 1 == 1);
    }
    return word;
  }

  /// Whether a stack of leaves is an even permutation of the bound
  /// order: an even count of swaps builds it. Every weave is even,
  /// so no weaving reaches an odd stack.
  static bool isEven(List<int> quire) {
    final seen = List<bool>.filled(quire.length, false);
    var even = true;
    for (var at = 0; at < quire.length; at++) {
      if (seen[at]) continue;
      var walk = at;
      var round = 0;
      while (!seen[walk]) {
        seen[walk] = true;
        walk = quire[walk];
        round++;
      }
      if (round.isEven) even = !even;
    }
    return even;
  }

  /// Every stack the two weaves can reach from [start], each with its
  /// fewest weaves. Small for a quire of eight: twenty-four stacks.
  static Map<String, int> orbit(List<int> start) {
    final found = <String, int>{_key(start): 0};
    var edge = [start];
    var weaves = 0;
    while (edge.isNotEmpty) {
      weaves++;
      final next = <List<int>>[];
      for (final quire in edge) {
        for (final inward in const [false, true]) {
          final woven = weave(quire, inward);
          final key = _key(woven);
          if (!found.containsKey(key)) {
            found[key] = weaves;
            next.add(woven);
          }
        }
      }
      edge = next;
    }
    return found;
  }

  /// Fewest weaves from [start] until [isDone], walking every
  /// weaving; -1 when no weaving ever gets there.
  static int fewest(List<int> start, bool Function(List<int>) isDone) {
    if (isDone(start)) return 0;
    final seen = <String>{_key(start)};
    var edge = [start];
    var weaves = 0;
    while (edge.isNotEmpty) {
      weaves++;
      final next = <List<int>>[];
      for (final quire in edge) {
        for (final inward in const [false, true]) {
          final woven = weave(quire, inward);
          if (isDone(woven)) return weaves;
          if (seen.add(_key(woven))) next.add(woven);
        }
      }
      edge = next;
    }
    return -1;
  }

  /// The weave that brings [isDone] nearest, or null when neither
  /// does: true for in, false for out.
  static bool? bestWeave(List<int> quire, bool Function(List<int>) isDone) {
    var best = -1;
    bool? way;
    for (final inward in const [false, true]) {
      final after = fewest(weave(quire, inward), isDone);
      if (after == -1) continue;
      if (best == -1 || after < best) {
        best = after;
        way = inward;
      }
    }
    return way;
  }

  /// How many out-weaves alone bring a bound quire of [leaves] back
  /// to itself, by walking it round.
  static int comeRound(int leaves) {
    final bound = [for (var at = 0; at < leaves; at++) at];
    var quire = weaveOut(bound);
    var weaves = 1;
    while (!_same(quire, bound)) {
      quire = weaveOut(quire);
      weaves++;
    }
    return weaves;
  }

  /// The same count from figures alone: the least k with 2^k leaving
  /// remainder 1 by leaves - 1. An out-weave doubles every seat by
  /// that remainder.
  static int comeRoundByFigures(int leaves) {
    var power = 2 % (leaves - 1);
    var weaves = 1;
    while (power != 1) {
      power = power * 2 % (leaves - 1);
      weaves++;
    }
    return weaves;
  }

  static bool _same(List<int> a, List<int> b) {
    for (var at = 0; at < a.length; at++) {
      if (a[at] != b[at]) return false;
    }
    return true;
  }

  static String _key(List<int> quire) => quire.join(',');
}
