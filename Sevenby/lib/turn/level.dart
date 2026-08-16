import 'rules.dart';

/// One ask: a fraction to dial, for the way its decimal comes round.
class Level {
  const Level({
    required this.name,
    required this.kind,
    this.period,
    required this.ways,
    required this.note,
  });

  final String name;

  /// 'period': the decimal repeats every [period] places; 'full': every
  /// p - 1 places; 'rotation': a fraction over seven other than a
  /// seventh; 'longer': a period past p - 1.
  final String kind;

  final int? period;

  /// How many settings land it, from the sweep.
  final int ways;

  /// Something worth knowing, computed.
  final String note;

  bool get winnable => ways > 0;

  /// Whether k over p lands the ask.
  bool meets(int p, int k) {
    if (!Rules.primes.contains(p) || k < 1 || k >= p) return false;
    final n = Rules.periodByDivision(k, p);
    switch (kind) {
      case 'period':
        return n == period;
      case 'full':
        return n == p - 1;
      case 'rotation':
        return p == 7 && k != 1;
      default:
        return n > p - 1;
    }
  }

  /// The setting the pointer dials towards, the sweep's first, or null.
  (int, int)? get aim {
    for (final p in Rules.primes) {
      for (var k = 1; k < p; k++) {
        if (meets(p, k)) return (p, k);
      }
    }
    return null;
  }

  /// The task, told in words for the ledger.
  String get task {
    switch (kind) {
      case 'period':
        return 'dial a fraction whose decimal comes round every ${_word(period!)} places';
      case 'full':
        return 'dial a fraction whose decimal takes the whole turn to come round, p - 1 places';
      case 'rotation':
        return 'dial a fraction over seven, not a seventh itself, and read the digits of a seventh from another start';
      default:
        return 'dial a fraction whose decimal takes more than p - 1 places to come round';
    }
  }

  static String _word(int n) => const ['nought', 'one', 'two', 'three', 'four', 'five', 'six', 'seven', 'eight', 'nine', 'ten'][n];
}
