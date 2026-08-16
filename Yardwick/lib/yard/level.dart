import 'rules.dart';

/// One ask: what the two counts are to make of the yardstick.
class Level {
  const Level({
    required this.name,
    required this.kind,
    required this.ways,
    required this.note,
  });

  final String name;

  /// 'five': the yardstick five; 'sly': the hedges coprime though the
  /// counts share a factor, both counts above two; 'whole': the first
  /// hedge measures the second exactly, the first count from three up
  /// and below the second; 'long': the yardstick 55 or longer; 'odd':
  /// the hedges sharing a factor while the counts share none, which
  /// never happens.
  final String kind;

  /// How many settings land it, from the sweep.
  final int ways;

  /// Something worth knowing, computed.
  final String note;

  bool get winnable => ways > 0;

  /// Whether the counts [m] and [n] land the ask.
  bool meets(int m, int n) {
    if (m < 1 || m > Rules.most || n < 1 || n > Rules.most) return false;
    final measure = Rules.measureByHedges(m, n);
    switch (kind) {
      case 'five':
        return measure == BigInt.from(5);
      case 'sly':
        return measure == BigInt.one && Rules.gcd(m, n) > 1 && m >= 3 && n >= 3;
      case 'whole':
        return m >= 3 && m < n && Rules.divides(m, n);
      case 'long':
        return measure >= BigInt.from(55);
      default:
        return measure > BigInt.one && Rules.gcd(m, n) == 1;
    }
  }

  /// The setting the pointer works towards, the sweep's first that lands
  /// the ask, or null.
  (int, int)? get aim {
    for (var m = 1; m <= Rules.most; m++) {
      for (var n = 1; n <= Rules.most; n++) {
        if (meets(m, n)) return (m, n);
      }
    }
    return null;
  }

  /// The task, told in words for the ledger.
  String get task {
    switch (kind) {
      case 'five':
        return 'set the two counts so that the yardstick is five';
      case 'sly':
        return 'set two counts above two that share a factor while their hedges share none';
      case 'whole':
        return 'set the counts so that the first hedge, three or more, measures the longer second hedge exactly';
      case 'long':
        return 'set the two counts so that the yardstick is 55 or longer';
      default:
        return 'set two counts that share no factor while their hedges share one';
    }
  }
}
