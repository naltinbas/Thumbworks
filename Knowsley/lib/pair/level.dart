import 'rules.dart';

/// One ask: which of the things said are to hold, and of what.
class Level {
  const Level({
    required this.name,
    required this.kind,
    required this.ways,
    required this.note,
  });

  final String name;

  /// 'tells': P knows the numbers from the product at once; 'knew': S
  /// could say she knew P did not know; 'then': P knows once S has said
  /// so; 'both': S knows too, all four things said; 'even': the sum even
  /// and S able to say she knew.
  final String kind;

  /// How many pairs land it, from the sieve.
  final int ways;

  /// Something worth knowing, computed.
  final String note;

  bool get winnable => ways > 0;

  /// Whether the pair (x, y) lands the ask.
  bool meets(int x, int y) {
    if (!Rules.valid(x, y)) return false;
    final (one, two, three, four) = Rules.said(x, y);
    switch (kind) {
      case 'tells':
        return !one;
      case 'knew':
        return two;
      case 'then':
        return three;
      case 'both':
        return four;
      default:
        return two && (x + y).isEven;
    }
  }

  /// The pair the pointer works towards, the sieve's first that lands
  /// the ask, or null.
  (int, int)? get aim {
    for (final (x, y) in Rules.pairs) {
      if (meets(x, y)) return (x, y);
    }
    return null;
  }

  /// The task, told in words for the ledger.
  String get task {
    switch (kind) {
      case 'tells':
        return 'set two numbers whose product tells P them at once';
      case 'knew':
        return 'set two numbers whose sum lets S say she knew P did not know';
      case 'then':
        return 'set two numbers P knows once S has said she knew he did not';
      case 'both':
        return 'set the two numbers S knows too, all four things said';
      default:
        return 'set two numbers with an even sum that lets S say she knew P did not know';
    }
  }
}
