/// The law of the yard.
///
/// Fleece bundles wait in the yard, each with its weight. A braid
/// joins two bundles into one and costs their weights put together;
/// the yard is done when one skein holds everything, and the work is
/// every braid's cost summed.
///
/// The least work is known two ways that share nothing. The
/// lightest-first rule braids the two lightest bundles every time
/// and never looks back; the sweep tries every braid order there is
/// and keeps the cheapest. On every yard that ships the two agree
/// to the pound, and the sweep also knows the dearest order and
/// everything between.
class Rules {
  /// The lightest-first rule's work, on a yard of weights.
  static int lightestFirst(List<int> weights) {
    final yard = List.of(weights)..sort();
    var work = 0;
    while (yard.length > 1) {
      yard.sort();
      final braid = yard[0] + yard[1];
      yard.removeRange(0, 2);
      yard.add(braid);
      work += braid;
    }
    return work;
  }

  static final Map<String, int> _least = {};
  static final Map<String, int> _most = {};

  /// The least work over every braid order, swept.
  static int leastWork(List<int> weights) =>
      _sweep(weights, _least, (a, b) => a < b);

  /// The dearest order's work, for the measure of the spread.
  static int mostWork(List<int> weights) =>
      _sweep(weights, _most, (a, b) => a > b);

  static int _sweep(List<int> weights, Map<String, int> memo,
      bool Function(int, int) beats) {
    if (weights.length == 1) return 0;
    final sorted = List.of(weights)..sort();
    final key = sorted.join(',');
    final held = memo[key];
    if (held != null) return held;
    int? best;
    for (var one = 0; one < sorted.length; one++) {
      for (var two = one + 1; two < sorted.length; two++) {
        final rest = <int>[
          for (var at = 0; at < sorted.length; at++)
            if (at != one && at != two) sorted[at],
          sorted[one] + sorted[two],
        ];
        final work =
            sorted[one] + sorted[two] + _sweep(rest, memo, beats);
        if (best == null || beats(work, best)) best = work;
      }
    }
    memo[key] = best!;
    return best;
  }

  /// How many braid orders a yard of [bundles] has in all: each
  /// step picks one pair of what remains.
  static int orders(int bundles) {
    var total = 1;
    for (var left = bundles; left > 1; left--) {
      total *= left * (left - 1) ~/ 2;
    }
    return total;
  }
}
