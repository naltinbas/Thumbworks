import 'gold.dart';

/// A pad on the mere: [x] across, [y] up, the reeds between
/// row nought and row one.
typedef Pad = (int, int);

/// A leap: the frog at [from] over the frog at [over] into the
/// empty pad at [to], and the frog leapt over is gone.
typedef Leap = ({Pad from, Pad over, Pad to});

/// The law of the mere.
///
/// Frogs on a grid of pads, all of them below the reeds to start,
/// leaping as in solitaire: over a neighbour into an empty pad
/// beyond, and the neighbour leaves. Conway asked in 1961 how
/// high above the reeds a frog can be got, and answered it with
/// a reckoning: give the pad aimed at the weight one, and every
/// other pad the weight of one over the golden ratio to the
/// power of its distance from that pad. A leap toward the aim
/// keeps the army's weight exactly, since one over phi and one
/// over phi squared add up to one, and every other leap loses.
/// The whole pond below the reeds, all of it, weighs exactly one
/// against the fifth reach, so any army you could set down weighs
/// less than one and never gets there. The first four reaches
/// are leapt to by two, four, eight and twenty frogs.
class Rules {
  Rules(this.reach, this.army);

  /// The row aimed at, above the reeds.
  final int reach;

  /// The frogs as set down.
  final List<Pad> army;

  Pad get aim => (0, reach);

  static const double goldenRatio = 1.618033988749895;

  /// Taxicab distance from a pad to the aim.
  int distance(Pad pad) => (pad.$1).abs() + (reach - pad.$2).abs();

  /// The pad's weight, as a number.
  double weight(Pad pad) => _phiToMinus(distance(pad));

  /// The pad's weight, exact.
  Gold exactWeight(Pad pad) => Gold.phiToMinus(distance(pad));

  double _phiToMinus(int k) {
    var out = 1.0;
    for (var i = 0; i < k; i++) {
      out /= goldenRatio;
    }
    return out;
  }

  /// An army's weight, as a number.
  double weightOf(Iterable<Pad> frogs) =>
      frogs.fold(0.0, (sum, pad) => sum + weight(pad));

  /// An army's weight, exact.
  Gold exactWeightOf(Iterable<Pad> frogs) =>
      frogs.fold(Gold.zero, (sum, pad) => sum + exactWeight(pad));

  static const _steps = [(1, 0), (-1, 0), (0, 1), (0, -1)];

  /// The leaps open from a standing of frogs.
  List<Leap> leaps(Set<Pad> frogs) => [
        for (final from in frogs)
          for (final (dx, dy) in _steps)
            if (frogs.contains((from.$1 + dx, from.$2 + dy)) &&
                !frogs.contains((from.$1 + 2 * dx, from.$2 + 2 * dy)))
              (
                from: from,
                over: (from.$1 + dx, from.$2 + dy),
                to: (from.$1 + 2 * dx, from.$2 + 2 * dy),
              ),
      ];

  /// The frogs after a leap.
  Set<Pad> after(Set<Pad> frogs, Leap leap) =>
      {...frogs}..remove(leap.from)..remove(leap.over)..add(leap.to);

  bool reached(Set<Pad> frogs) => frogs.contains(aim);

  /// How wide the count may wander: no road that lands ever
  /// needs a frog beyond here, and the checker holds it to that.
  static const wander = 9;
  static const depth = 11;

  bool _inside(Pad pad) =>
      pad.$1.abs() <= wander && pad.$2 >= -depth && pad.$2 <= reach;

  /// The roads from a standing to the aim: every order of leaps
  /// that lands, counted, with a leap that drops the weight
  /// below one thrown out, since no such standing can ever get
  /// back to the aim.
  int roads(Set<Pad> frogs, {Set<String>? touchedEdge}) {
    final memo = <String, int>{};
    int walk(Set<Pad> standing) {
      if (reached(standing)) return 1;
      final key = _key(standing);
      final known = memo[key];
      if (known != null) return known;
      var total = 0;
      final weightNow = weightOf(standing);
      for (final leap in leaps(standing)) {
        if (!_inside(leap.to)) {
          touchedEdge?.add('${leap.to}');
          continue;
        }
        final weightNext =
            weightNow - weight(leap.from) - weight(leap.over) + weight(leap.to);
        if (weightNext < 1 - 1e-9) continue;
        total += walk(after(standing, leap));
      }
      memo[key] = total;
      return total;
    }

    return walk(frogs);
  }

  /// The fewest leaps from a standing to the aim, or null when no
  /// road lands.
  int? fewest(Set<Pad> frogs) {
    final memo = <String, int?>{};
    int? walk(Set<Pad> standing) {
      if (reached(standing)) return 0;
      final key = _key(standing);
      if (memo.containsKey(key)) return memo[key];
      int? best;
      final weightNow = weightOf(standing);
      for (final leap in leaps(standing)) {
        if (!_inside(leap.to)) continue;
        final weightNext =
            weightNow - weight(leap.from) - weight(leap.over) + weight(leap.to);
        if (weightNext < 1 - 1e-9) continue;
        final then = walk(after(standing, leap));
        if (then != null && (best == null || then + 1 < best)) {
          best = then + 1;
        }
      }
      memo[key] = best;
      return best;
    }

    return walk(frogs);
  }

  /// A leap on some road from here, or null when no road lands.
  Leap? next(Set<Pad> frogs) {
    final dead = <String>{};
    Leap? seek(Set<Pad> standing) {
      if (reached(standing)) return null;
      final weightNow = weightOf(standing);
      for (final leap in leaps(standing)) {
        if (!_inside(leap.to)) continue;
        final weightNext =
            weightNow - weight(leap.from) - weight(leap.over) + weight(leap.to);
        if (weightNext < 1 - 1e-9) continue;
        final then = after(standing, leap);
        if (reached(then)) return leap;
        final key = _key(then);
        if (dead.contains(key)) continue;
        if (seek(then) != null) return leap;
        dead.add(key);
      }
      return null;
    }

    if (reached(frogs)) return null;
    return seek(frogs);
  }

  /// Whether any road lands from here.
  bool lands(Set<Pad> frogs) => reached(frogs) || next(frogs) != null;

  String _key(Set<Pad> standing) {
    final pads = standing.toList()
      ..sort((a, b) => a.$2 != b.$2 ? a.$2 - b.$2 : a.$1 - b.$1);
    return pads.map((p) => '${p.$1},${p.$2}').join(';');
  }

  /// The heaviest [count] pads below the reeds, added up: no
  /// army of that many frogs weighs more.
  double heaviest(int count) {
    final weights = <double>[
      for (var y = 0; y >= -depth - reach; y--)
        for (var x = -wander - reach; x <= wander + reach; x++)
          weight((x, y)),
    ]..sort((a, b) => b.compareTo(a));
    return weights.take(count).fold(0.0, (sum, w) => sum + w);
  }

  /// The same, exact.
  Gold heaviestExact(int count) {
    final pads = <Pad>[
      for (var y = 0; y >= -depth - reach; y--)
        for (var x = -wander - reach; x <= wander + reach; x++) (x, y),
    ]..sort((a, b) => distance(a) - distance(b));
    return exactWeightOf(pads.take(count));
  }

  /// The whole pond below the reeds weighed against the [reach],
  /// exact: the columns sum to phi to the minus reach times phi
  /// squared, since one less one over phi times phi squared is
  /// one, and each row to one plus twice phi by the same
  /// series, and the product is the answer.
  static Gold wholePond(int reach) {
    final column = Gold.phiToMinus(reach) * Gold.phi * Gold.phi;
    final row = Gold.one + Gold.phi.times(2);
    return column * row;
  }

  /// The series behind [wholePond], checked as arithmetic: one
  /// less one over phi, times phi squared, is one.
  static bool seriesHolds() =>
      (Gold.one - Gold.overPhi) * Gold.phi * Gold.phi == Gold.one;

  /// The pond below the reeds out to [span] pads each way,
  /// weighed as a number: creeps up toward the whole.
  static double pondOut(int reach, int span) {
    var total = 0.0;
    var unit = 1.0;
    for (var i = 0; i < reach; i++) {
      unit /= goldenRatio;
    }
    for (var y = 0; y >= -span; y--) {
      for (var x = -span; x <= span; x++) {
        var w = unit;
        for (var i = 0; i < x.abs() + (0 - y); i++) {
          w /= goldenRatio;
        }
        total += w;
      }
    }
    return total;
  }

  /// A leap straight toward the aim keeps the weight; checked
  /// exactly for every distance up to [upTo].
  static bool leapTowardKeeps(int upTo) {
    for (var d = 2; d <= upTo; d++) {
      final change = Gold.phiToMinus(d - 2) -
          Gold.phiToMinus(d - 1) -
          Gold.phiToMinus(d);
      if (change != Gold.zero) return false;
    }
    return true;
  }
}
