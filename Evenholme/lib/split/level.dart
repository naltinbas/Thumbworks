import 'rules.dart';

/// One ask: an even number to split into two primes, perhaps with a
/// condition on the pair.
class Level {
  const Level({
    required this.name,
    required this.number,
    this.kind = 'any',
    required this.ways,
    required this.note,
  });

  final String name;
  final int number;

  /// 'any': any two primes; 'twins': two apart; 'over': both over
  /// thirty.
  final String kind;

  /// How many picks land it, from the sweep.
  final int ways;

  /// Something worth knowing, computed.
  final String note;

  bool get winnable => ways > 0;

  /// The picks there are: the smaller of the two, 2 to half the number.
  int get picks => number ~/ 2 - 1;

  /// Whether the pick [a], with its partner number - a, lands the ask.
  bool meets(int a) {
    final b = number - a;
    if (a < 2 || b < 2 || !Rules.isPrime(a) || !Rules.isPrime(b)) return false;
    switch (kind) {
      case 'twins':
        return (a - b).abs() == 2;
      case 'over':
        return a > 30 && b > 30;
      default:
        return true;
    }
  }

  /// The pick the pointer works towards, the smallest that lands it, or
  /// null when none does.
  int? get aim {
    for (var a = 2; a <= number ~/ 2; a++) {
      if (meets(a)) return a;
    }
    return null;
  }

  /// The task, told in words for the ledger.
  String get task {
    switch (kind) {
      case 'twins':
        return 'split $number into two primes two apart';
      case 'over':
        return 'split $number into two primes both over thirty';
      default:
        return 'split $number into two primes';
    }
  }
}
