import 'rules.dart';

/// One ask: a clock, locked or free, and what the base's walk must touch.
class Level {
  const Level({
    required this.name,
    this.clock,
    this.least = Rules.least,
    required this.kind,
    required this.ways,
    required this.note,
  });

  final String name;

  /// The clock the ask is set on, or null when the clock dial is free.
  final int? clock;

  /// The fewest hours a free clock may have for the ask.
  final int least;

  /// 'all': the walk touches every hour but 0; 'units': it touches every
  /// hour sharing no factor with the clock; 'four': the fourth power is
  /// the first to come home.
  final String kind;

  /// How many settings land it, from the sweep.
  final int ways;

  /// Something worth knowing, computed.
  final String note;

  bool get winnable => ways > 0;

  bool get locked => clock != null;

  /// The settings the ask is swept over: the bases of a locked clock, or
  /// every base of every clock.
  int get settings => locked ? clock! - 1 : Rules.settings;

  /// Whether [base] on clock [c] lands the ask.
  bool meets(int c, int base) {
    if (locked ? c != clock : c < least) return false;
    if (base < 1 || base >= c) return false;
    switch (kind) {
      case 'all':
        return Rules.orderByWalk(base, c) == c - 1;
      case 'units':
        return Rules.isFull(base, c);
      default:
        return Rules.orderByWalk(base, c) == 4;
    }
  }

  /// The setting the pointer walks to, the sweep's first, or null.
  (int, int)? get aim {
    for (var c = locked ? clock! : least; c <= (locked ? clock! : Rules.most); c++) {
      for (var b = 1; b < c; b++) {
        if (meets(c, b)) return (c, b);
      }
    }
    return null;
  }

  /// The task, told in words for the ledger.
  String get task {
    final where = locked ? 'the ${Rules.name(clock!)}-hour clock' : 'a clock';
    switch (kind) {
      case 'all':
        return locked
            ? 'set the base so its walk touches every hour of $where but 0'
            : 'find a clock of ${Rules.name(least)} hours or more and a base whose walk touches every hour but 0';
      case 'units':
        return 'set the base so its walk touches every hour of $where that shares no factor with ${Rules.name(clock!)}, ${Rules.told(Rules.units(clock!))}';
      default:
        return 'find a clock and a base whose fourth power is the first to come home to 1';
    }
  }
}
