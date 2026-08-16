import 'rules.dart';

/// One ask: a clock, locked or free, and where the base's square is to
/// land, or where the base itself is to stand.
class Level {
  const Level({
    required this.name,
    this.clock,
    required this.kind,
    required this.ways,
    required this.note,
  });

  final String name;

  /// The clock the ask is set on, or null when the clock dial is free.
  final int? clock;

  /// 'two': the base's square is 2; 'minusOne': the base's square is one
  /// short of the clock; 'nonSquare': the base stands on an hour no base
  /// squares to.
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

  /// Whether [base] on clock [p] lands the ask.
  bool meets(int p, int base) {
    if (locked && p != clock) return false;
    if (base < 1 || base >= p) return false;
    switch (kind) {
      case 'two':
        return base * base % p == 2 % p;
      case 'minusOne':
        return base * base % p == p - 1;
      default:
        return !Rules.squaresByBases(p).contains(base);
    }
  }

  /// The setting the pointer walks to, the sweep's first, or null.
  (int, int)? get aim {
    for (final p in Rules.clocks) {
      for (var b = 1; b < p; b++) {
        if (meets(p, b)) return (p, b);
      }
    }
    return null;
  }

  /// The task, told in words for the ledger.
  String get task {
    final where = locked ? 'on the ${Rules.name(clock!)}-hour clock' : 'and a clock';
    switch (kind) {
      case 'two':
        return locked ? 'dial a base $where whose square is 2' : 'dial a base $where so that the square is 2';
      case 'minusOne':
        return locked ? 'dial a base $where whose square is one short of the clock' : 'dial a base $where so that the square is one short of the clock';
      default:
        return 'dial a base $where standing on an hour that no base squares to';
    }
  }
}
