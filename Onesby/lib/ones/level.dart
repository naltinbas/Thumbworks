import 'rules.dart';

/// One ask: an exponent to dial, for the row of ones it makes.
class Level {
  const Level({
    required this.name,
    required this.kind,
    required this.ways,
    required this.note,
  });

  final String name;

  /// 'primeNot': a prime exponent whose row is composite; 'twentyThree':
  /// 23 divides the row; 'perfect': the row makes 8,128; 'longest': the
  /// longest prime row on the dial; 'composite': a composite exponent
  /// whose row is prime.
  final String kind;

  /// How many exponents land it, from the sweep.
  final int ways;

  /// Something worth knowing, computed.
  final String note;

  bool get winnable => ways > 0;

  /// Whether the exponent [p] lands the ask.
  bool meets(int p) {
    if (p < Rules.least || p > Rules.most) return false;
    switch (kind) {
      case 'primeNot':
        return Rules.isPrime(p) && !Rules.rowIsPrimeByDivision(p);
      case 'twentyThree':
        return Rules.row(p) % BigInt.from(23) == BigInt.zero;
      case 'perfect':
        return Rules.rowIsPrimeByDivision(p) && Rules.perfect(p) == BigInt.from(8128);
      case 'longest':
        if (!Rules.rowIsPrimeByDivision(p)) return false;
        for (var q = p + 1; q <= Rules.most; q++) {
          if (Rules.rowIsPrimeByDivision(q)) return false;
        }
        return true;
      default:
        return !Rules.isPrime(p) && Rules.rowIsPrimeByDivision(p);
    }
  }

  /// The exponent the pointer winds towards, the sweep's first, or null.
  int? get aim {
    for (var p = Rules.least; p <= Rules.most; p++) {
      if (meets(p)) return p;
    }
    return null;
  }

  /// The task, told in words for the ledger.
  String get task {
    switch (kind) {
      case 'primeNot':
        return 'dial a prime exponent whose row of ones is not prime';
      case 'twentyThree':
        return 'dial an exponent whose row of ones 23 divides';
      case 'perfect':
        return 'dial the exponent whose prime row makes the perfect number 8,128';
      case 'longest':
        return 'dial the longest row of ones the dial holds that is prime';
      default:
        return 'dial a composite exponent whose row of ones is prime';
    }
  }
}
