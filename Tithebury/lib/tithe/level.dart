import 'rules.dart';

/// One ask: a number to find by its tithe.
class Level {
  const Level({
    required this.name,
    required this.kind,
    required this.ways,
    required this.aim,
    required this.note,
  });

  final String name;

  /// 'perfect': the tithe is the number; 'friends': the tithe's tithe is
  /// the number and the tithe is not; 'abundantSmall': under twenty and
  /// the tithe over the number; 'twice': the tithe is twice the number;
  /// 'powerOfTwo': a power of two whose tithe is itself.
  final String kind;

  /// How many of the settings land it, from the sweep.
  final int ways;

  /// The number the pointer walks to, or null when none lands it.
  final int? aim;

  /// Something worth knowing, computed.
  final String note;

  bool get winnable => ways > 0;

  /// Whether the number lands the ask.
  bool meets(int n) {
    final t = Rules.tithe(n);
    switch (kind) {
      case 'perfect':
        return t == n;
      case 'friends':
        return t != n && t >= 1 && Rules.tithe(t) == n;
      case 'abundantSmall':
        return n < 20 && t > n;
      case 'twice':
        return t == 2 * n;
      default:
        return Rules.isPowerOfTwo(n) && t == n;
    }
  }

  /// The task, told in words for the ledger.
  String get task {
    switch (kind) {
      case 'perfect':
        return 'set the number so its proper divisors add up to it exactly';
      case 'friends':
        return 'set the number so its proper divisors add up to a different number whose proper divisors add up to it';
      case 'abundantSmall':
        return 'set the number, under twenty, so its proper divisors add up to more than it';
      case 'twice':
        return 'set the number so its proper divisors add up to exactly twice it';
      default:
        return 'set the number, a power of two, so its proper divisors add up to it exactly';
    }
  }
}
