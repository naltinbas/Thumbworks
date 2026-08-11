import 'consignment.dart';
import 'rules.dart';

/// A stacking part chosen: which rope of each crate serves which line.
class Play {
  const Play._(this.consignment, this.picks, this.before);

  Play.of(Consignment consignment)
      : this._(consignment,
            List.unmodifiable(List.filled(4, (-1, -1))), null);

  final Consignment consignment;

  /// picks[crate] = (nsPairIndex, ewPairIndex), -1 while unchosen.
  final List<(int, int)> picks;

  /// The stacking before the last choice, or null at the start.
  final Play? before;

  int get chosenCount {
    var count = 0;
    for (final (ns, ew) in picks) {
      if (ns >= 0) count++;
      if (ew >= 0) count++;
    }
    return count;
  }

  bool get isComplete => chosenCount == 8;

  /// What a chip serves: 'ns', 'ew', or null.
  String? serves(int crate, int pair) {
    if (picks[crate].$1 == pair) return 'ns';
    if (picks[crate].$2 == pair) return 'ew';
    return null;
  }

  /// The chosen ropes of a line, for the crates that have chosen.
  List<(int, int)> lineRopes(bool ns) => [
        for (var crate = 0; crate < 4; crate++)
          if ((ns ? picks[crate].$1 : picks[crate].$2) >= 0)
            consignment.crates[crate]
                [ns ? picks[crate].$1 : picks[crate].$2],
      ];

  /// Rope-ends per paint on a line so far.
  List<int> endsOn(bool ns) {
    final ends = List<int>.filled(4, 0);
    for (final (a, b) in lineRopes(ns)) {
      ends[a]++;
      ends[b]++;
    }
    return ends;
  }

  /// Whether the stack stands fair: complete, both lines fair.
  bool get isStacked =>
      isComplete &&
      Rules.fair(lineRopes(true)) &&
      Rules.fair(lineRopes(false));

  /// Cycles a chip: free -> north-south -> east-west -> free, skipping
  /// roles another chip of the crate holds. Returns this unchanged when
  /// nothing can change.
  Play cycle(int crate, int pair) {
    if (crate < 0 || crate >= 4 || pair < 0 || pair >= 3) return this;
    final (ns, ew) = picks[crate];
    (int, int)? next;
    if (ns == pair) {
      // ns -> ew when free, else -> free.
      next = ew < 0 ? (-1, pair) : (-1, ew);
    } else if (ew == pair) {
      next = (ns, -1);
    } else {
      // free -> ns when free, else ew when free, else nothing.
      if (ns < 0) {
        next = (pair, ew);
      } else if (ew < 0) {
        next = (ns, pair);
      } else {
        return this;
      }
    }
    return Play._(
      consignment,
      List.unmodifiable([
        for (var at = 0; at < 4; at++) at == crate ? next : picks[at],
      ]),
      this,
    );
  }

  /// The last choice back, or this at the start.
  Play get back => before ?? this;

  /// Whether a fair stack can still be reached from here.
  bool get canStill =>
      Rules.canStillStack(consignment.crates, [...picks]);

  /// A chip and role that keeps the stack reachable, as (crate, pair,
  /// 'ns' or 'ew'), or null.
  (int, int, String)? get next {
    if (isStacked || !canStill) return null;
    for (var crate = 0; crate < 4; crate++) {
      final (ns, ew) = picks[crate];
      if (ns >= 0 && ew >= 0) continue;
      for (var pair = 0; pair < 3; pair++) {
        if (serves(crate, pair) != null) continue;
        if (ns < 0) {
          final tried = cycle(crate, pair);
          if (Rules.canStillStack(consignment.crates, [...tried.picks])) {
            return (crate, pair, 'ns');
          }
        } else {
          final tried = cycle(crate, pair);
          if (Rules.canStillStack(consignment.crates, [...tried.picks])) {
            return (crate, pair, 'ew');
          }
        }
      }
      return null;
    }
    return null;
  }
}
