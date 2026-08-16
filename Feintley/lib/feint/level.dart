import 'rules.dart';

/// One ask: what number and base are to be set, and what the test is
/// to say.
class Level {
  const Level({
    required this.name,
    required this.kind,
    required this.ways,
    required this.note,
  });

  final String name;

  /// 'honest': a prime above a thousand, passing; 'two': a liar for base
  /// two; 'three': a liar for base three; 'carmichael': a Carmichael
  /// number on a base it shares no factor with; 'failing': a prime that
  /// fails on a base it does not divide, which there never is.
  final String kind;

  /// How many settings land it, from the sweep.
  final int ways;

  /// Something worth knowing, computed.
  final String note;

  bool get winnable => ways > 0;

  /// Whether the number [n] on the base [a] lands the ask.
  bool meets(int n, int a) {
    if (n < Rules.least || n > Rules.most || a < Rules.leastBase || a > Rules.mostBase) return false;
    switch (kind) {
      case 'honest':
        return n > 1000 && Rules.isPrime(n) && Rules.passes(a, n);
      case 'two':
        return a == 2 && Rules.liar(2, n);
      case 'three':
        return a == 3 && Rules.liar(3, n);
      case 'carmichael':
        return Rules.carmichael(n) && Rules.gcd(a, n) == 1;
      default:
        return Rules.isPrime(n) && Rules.gcd(a, n) == 1 && !Rules.passes(a, n);
    }
  }

  /// The setting the pointer works towards, the sweep's first that lands
  /// the ask, or null.
  (int, int)? get aim {
    for (var n = Rules.least; n <= Rules.most; n++) {
      for (var a = Rules.leastBase; a <= Rules.mostBase; a++) {
        if (meets(n, a)) return (n, a);
      }
    }
    return null;
  }

  /// The task, told in words for the ledger.
  String get task {
    switch (kind) {
      case 'honest':
        return 'set a prime above a thousand and a base, and have it pass';
      case 'two':
        return 'set a composite that passes on base two';
      case 'three':
        return 'set a composite that passes on base three';
      case 'carmichael':
        return 'set a composite that passes on every base it shares no factor with, and such a base';
      default:
        return 'set a prime and a base it does not divide, and have it fail';
    }
  }
}
