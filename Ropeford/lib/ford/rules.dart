/// A ford of numbered stepping stones, 1 to 120, laid across a river.
/// The dry stones are the primes; the rest are mossy and half sunk and
/// will not take a foot. Standing on stone n, the rope reaches exactly
/// as far as 2n, and a hop may go to any dry stone past n and no
/// further than the rope's end.
///
/// Bertrand's postulate, put by Joseph Bertrand in 1845 in the stronger
/// form n < p < 2n - 2 and proved by Pafnuty Chebyshev in 1850, is that
/// there is always a dry stone in reach: for every n greater than 1
/// there is a prime p with n < p < 2n. So the numbers can never strand
/// you, though the ford still can, since it stops at 120: from stone
/// 113 the next dry stone, 127, is past its end. What the postulate
/// never says is where the next dry stone will be.
class Rules {
  /// The ford's stones, 1 to [stones].
  static const stones = 120;

  /// Where the crossing starts, the first dry stone.
  static const start = 2;

  /// The run of mossy stones the hopeless ask points at, the first run
  /// of seven in a row anywhere.
  static const shallowsFrom = 90, shallowsTo = 96;

  static final List<bool> _dry = sieve(stones);

  /// Eratosthenes over 0 to [n]: the first voice on what is dry.
  static List<bool> sieve(int n) {
    final dry = List.filled(n + 1, true);
    if (n >= 0) dry[0] = false;
    if (n >= 1) dry[1] = false;
    for (var i = 2; i * i <= n; i++) {
      if (dry[i]) {
        for (var j = i * i; j <= n; j += i) {
          dry[j] = false;
        }
      }
    }
    return dry;
  }

  /// Dryness worked out the other way about, by trial division: the
  /// second voice, which knows nothing of the sieve.
  static bool dryByTrial(int k) {
    if (k < 2) return false;
    if (k.isEven) return k == 2;
    for (var d = 3; d * d <= k; d += 2) {
      if (k % d == 0) return false;
    }
    return true;
  }

  /// The smallest whole number above one that divides [k], which is [k]
  /// itself when [k] is dry.
  static int factorOf(int k) {
    if (k < 2) return k;
    if (k.isEven) return 2;
    for (var d = 3; d * d <= k; d += 2) {
      if (k % d == 0) return d;
    }
    return k;
  }

  static bool onFord(int k) => k >= 1 && k <= stones;

  static bool dry(int k) => onFord(k) && _dry[k];

  static bool mossy(int k) => onFord(k) && !_dry[k];

  /// The dry stones of the ford, in order.
  static final List<int> dryStones = [
    for (var k = 1; k <= stones; k++)
      if (_dry[k]) k,
  ];

  /// Where the rope from [n] ends.
  static int ropeEnd(int n) => 2 * n;

  /// Whether the rope from [n] runs past the ford's last stone.
  static bool ropePastFord(int n) => ropeEnd(n) > stones;

  /// The dry stones the rope from [n] covers.
  static List<int> inReach(int n) =>
      [for (final p in dryStones) if (p > n && p <= ropeEnd(n)) p];

  /// Whether a hop from [from] to [to] is a fair one.
  static bool canHop(int from, int to) =>
      dry(to) && to > from && to <= ropeEnd(from);

  /// The farthest dry stone the rope from [n] covers, or null when the
  /// ford ends before any of it does.
  static int? farthest(int n) {
    final reach = inReach(n);
    return reach.isEmpty ? null : reach.last;
  }

  /// The crossing that always takes the farthest stone in reach, from
  /// [from] to the end of the ford. It is a certificate of the kind the
  /// small cases of the postulate are settled with, each stone under
  /// twice the one before.
  static List<int> chainFrom(int from) {
    final walk = [from];
    for (var far = farthest(from); far != null; far = farthest(walk.last)) {
      walk.add(far);
    }
    return walk;
  }

  /// The greedy crossing from the ford's first dry stone.
  static List<int> get chain => chainFrom(start);

  /// The fewest hops from [from] to every dry stone it can reach.
  static Map<int, int> walk(int from) {
    final far = <int, int>{from: 0};
    final queue = <int>[from];
    for (var head = 0; head < queue.length; head++) {
      final here = queue[head];
      for (final there in inReach(here)) {
        if (!far.containsKey(there)) {
          far[there] = far[here]! + 1;
          queue.add(there);
        }
      }
    }
    return far;
  }

  /// The fewest hops from the ford's first dry stone to each of the
  /// rest.
  static final Map<int, int> hops = walk(start);

  /// The stone to hop to from [from] on a shortest crossing to one the
  /// ask [likes], or null when there is no such stone or [from] is
  /// already one.
  static int? towards(int from, bool Function(int) likes) {
    if (likes(from)) return null;
    final first = <int, int>{from: from};
    final queue = <int>[from];
    for (var head = 0; head < queue.length; head++) {
      final here = queue[head];
      for (final there in inReach(here)) {
        if (first.containsKey(there)) continue;
        first[there] = here == from ? there : first[here]!;
        if (likes(there)) return first[there];
        queue.add(there);
      }
    }
    return null;
  }

  /// Whether the rope from [n] covers the whole of the long shallows,
  /// so a player standing there can see all seven mossy stones at once.
  static bool coversShallows(int n) =>
      n < shallowsFrom && ropeEnd(n) >= shallowsTo;

  /// Whether [p] is dry with nothing but moss for four stones either
  /// side of it.
  static bool lonely(int p) {
    if (!dry(p)) return false;
    for (var k = p - 4; k <= p + 4; k++) {
      if (k != p && dry(k)) return false;
    }
    return true;
  }

  /// Whether [p] is dry and has another dry stone two behind it.
  static bool upperTwin(int p) => dry(p) && dry(p - 2);

  /// Why a mossy stone will not take a foot: its smallest divisor and
  /// what it leaves.
  static String tellMoss(int k) {
    if (k == 1) return 'stone 1 is the near bank';
    final d = factorOf(k);
    return d == 2 ? 'stone $k is even' : 'stone $k is $d times ${k ~/ d}';
  }
}
