import 'dart:typed_data';

/// The law of the pails.
///
/// Pails of known capacity, a spring, and a drain. A pour fills a pail
/// at the spring, empties one at the drain, or tips one into another
/// until the first is dry or the second is full. The errand is done
/// when some pail holds the asked measure.
///
/// The fewest pours is known from a walk of every waterline there is;
/// the impossible errands are known twice, by the walk finding nothing
/// and by the shared measure: every pour keeps every pail a multiple
/// of the capacities' common measure.
class Rules {
  Rules(this.caps) {
    _walk();
  }

  final List<int> caps;

  int get pails => caps.length;

  int get states {
    var count = 1;
    for (final cap in caps) {
      count *= cap + 1;
    }
    return count;
  }

  /// Waterlines packed into one number, first pail lowest.
  int pack(List<int> held) {
    var state = 0;
    for (var pail = pails - 1; pail >= 0; pail--) {
      state = state * (caps[pail] + 1) + held[pail];
    }
    return state;
  }

  List<int> unpack(int state) {
    final held = <int>[];
    var rest = state;
    for (var pail = 0; pail < pails; pail++) {
      held.add(rest % (caps[pail] + 1));
      rest ~/= caps[pail] + 1;
    }
    return held;
  }

  /// The common measure of the capacities.
  int get measure {
    var g = caps.first;
    for (final cap in caps) {
      var a = g;
      var b = cap;
      while (b != 0) {
        final r = a % b;
        a = b;
        b = r;
      }
      g = a;
    }
    return g;
  }

  /// Every pour from a waterline: (from, to) with -1 the spring on one
  /// side and -2 the drain on the other.
  List<(int, int)> pours(List<int> held) => [
        for (var pail = 0; pail < pails; pail++) ...[
          if (held[pail] < caps[pail]) (-1, pail),
          if (held[pail] > 0) (pail, -2),
        ],
        for (var from = 0; from < pails; from++)
          for (var to = 0; to < pails; to++)
            if (from != to && held[from] > 0 && held[to] < caps[to])
              (from, to),
      ];

  /// One pour, waterlines in, waterlines out.
  List<int> poured(List<int> held, int from, int to) {
    final next = [...held];
    if (from == -1) {
      next[to] = caps[to];
    } else if (to == -2) {
      next[from] = 0;
    } else {
      final moved = next[from] < caps[to] - next[to]
          ? next[from]
          : caps[to] - next[to];
      next[from] -= moved;
      next[to] += moved;
    }
    return next;
  }

  /// How many pours each waterline is from all-dry, walked breadth
  /// first.
  late final Uint8List fromStart;

  void _walk() {
    fromStart = Uint8List(states)..fillRange(0, states, 255);
    final dry = pack(List<int>.filled(pails, 0));
    fromStart[dry] = 0;
    var edge = [dry];
    while (edge.isNotEmpty) {
      final next = <int>[];
      for (final state in edge) {
        final held = unpack(state);
        for (final (from, to) in pours(held)) {
          final there = pack(poured(held, from, to));
          if (fromStart[there] != 255) continue;
          fromStart[there] = fromStart[state] + 1;
          next.add(there);
        }
      }
      edge = next;
    }
  }

  /// The fewest pours from all-dry to any waterline holding the
  /// measure asked, or null when no waterline does.
  int? fewestTo(int asked) {
    int? best;
    for (var state = 0; state < states; state++) {
      if (fromStart[state] == 255) continue;
      final held = unpack(state);
      if (!held.contains(asked)) continue;
      if (best == null || fromStart[state] < best) {
        best = fromStart[state];
      }
    }
    return best;
  }

  /// How many pours from this waterline until some pail holds the
  /// asked measure, walked fresh backwards from every holding line.
  /// Cached per ask.
  final _toAsk = <int, Uint8List>{};

  Uint8List _distancesTo(int asked) => _toAsk[asked] ??= () {
        // The state space is tiny: seed the holding lines and relax
        // by rounds until nothing moves.
        final distance = Uint8List(states)..fillRange(0, states, 255);
        for (var state = 0; state < states; state++) {
          if (unpack(state).contains(asked)) distance[state] = 0;
        }
        var moved = true;
        while (moved) {
          moved = false;
          for (var state = 0; state < states; state++) {
            final held = unpack(state);
            for (final (from, to) in pours(held)) {
              final there = pack(poured(held, from, to));
              if (distance[there] == 255) continue;
              if (distance[state] > distance[there] + 1) {
                distance[state] = distance[there] + 1;
                moved = true;
              }
            }
          }
        }
        return distance;
      }();

  /// The fewest pours from a waterline to the ask, or null.
  int? fewestFrom(List<int> held, int asked) {
    final away = _distancesTo(asked)[pack(held)];
    return away == 255 ? null : away;
  }

  /// A pour that steps one nearer the ask, or null.
  (int, int)? next(List<int> held, int asked) {
    final distance = _distancesTo(asked);
    final here = distance[pack(held)];
    if (here == 0 || here == 255) return null;
    for (final (from, to) in pours(held)) {
      if (distance[pack(poured(held, from, to))] == here - 1) {
        return (from, to);
      }
    }
    return null;
  }

  /// Every measure any reachable waterline ever holds.
  Set<int> reachableMeasures() {
    final seen = <int>{};
    for (var state = 0; state < states; state++) {
      if (fromStart[state] == 255) continue;
      seen.addAll(unpack(state));
    }
    return seen;
  }
}
