import 'rules.dart';

/// One ask: a number to dial with a root and a shape.
class Level {
  const Level({
    required this.name,
    required this.kind,
    required this.ways,
    required this.note,
  });

  final String name;

  /// 'nine': three different digits, root nine; 'square7': a square
  /// with root seven; 'cube8': a cube with root eight; 'slip': root nine
  /// and not 846; 'square5': a square with root five.
  final String kind;

  /// How many of the thousand land it, from the sweep.
  final int ways;

  /// Something worth knowing, computed.
  final String note;

  bool get winnable => ways > 0;

  /// Whether the number [n] lands the ask.
  bool meets(int n) {
    final root = Rules.rootByDigits(n);
    switch (kind) {
      case 'nine':
        return Rules.allDifferent(n) && root == 9;
      case 'square7':
        return Rules.isSquare(n) && root == 7;
      case 'cube8':
        return Rules.isCube(n) && root == 8;
      case 'slip':
        return root == 9 && n != Rules.product;
      default:
        return Rules.isSquare(n) && root == 5;
    }
  }

  /// The number the pointer dials towards, the sweep's first, or null.
  int? get aim {
    for (var n = 0; n <= Rules.most; n++) {
      if (meets(n)) return n;
    }
    return null;
  }

  /// The task, told in words for the ledger.
  String get task {
    switch (kind) {
      case 'nine':
        return 'dial three different digits whose number has root nine';
      case 'square7':
        return 'dial a square whose root is seven';
      case 'cube8':
        return 'dial a cube whose root is eight';
      case 'slip':
        return 'dial a wrong answer to ${Rules.factors.$1} times ${Rules.factors.$2} that casting out nines lets through';
      default:
        return 'dial a square whose root is five';
    }
  }
}
