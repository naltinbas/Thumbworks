import 'rules.dart';

/// One ask: a clock to dial, for the period its Fibonacci numbers show.
class Level {
  const Level({
    required this.name,
    required this.kind,
    this.period,
    required this.ways,
    required this.note,
  });

  final String name;

  /// 'period': the period is [period]; 'own': the period is the clock's
  /// own length; 'odd': the clock is past two and its period odd.
  final String kind;

  final int? period;

  /// How many clocks land it, from the sweep.
  final int ways;

  /// Something worth knowing, computed.
  final String note;

  bool get winnable => ways > 0;

  /// Whether the clock of [m] hours lands the ask.
  bool meets(int m) {
    if (m < Rules.least || m > Rules.most) return false;
    final p = Rules.periodByWalk(m);
    switch (kind) {
      case 'period':
        return p == period;
      case 'own':
        return p == m;
      default:
        return m > 2 && p.isOdd;
    }
  }

  /// The clock the pointer winds towards, the sweep's first, or null.
  int? get aim {
    for (var m = Rules.least; m <= Rules.most; m++) {
      if (meets(m)) return m;
    }
    return null;
  }

  /// The task, told in words for the ledger.
  String get task {
    switch (kind) {
      case 'period':
        return 'dial a clock on which the Fibonacci numbers come round every $period steps';
      case 'own':
        return 'dial a clock whose period is as long as the clock itself';
      default:
        return 'dial a clock past two hours whose period is odd';
    }
  }
}
