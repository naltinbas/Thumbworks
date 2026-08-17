import 'frac.dart';
import 'rules.dart';

/// One ask: what the run of casks is to come to.
class Level {
  const Level({
    required this.name,
    required this.kind,
    required this.mark,
    required this.ways,
    required this.aim,
    required this.note,
  });

  final String name;

  /// 'past': the total to pass [mark] barrels; 'halves': the total to
  /// come out in halves exactly; 'whole': the total to be a whole
  /// number of barrels, which never happens.
  final String kind;

  /// The mark the ask is against.
  final int mark;

  /// How many runs land it, from the sweep.
  final int ways;

  /// The cheapest run that lands it, from the sweep; null when none
  /// does.
  final (int, int)? aim;

  /// Something worth knowing, written out by hand.
  final String note;

  bool get winnable => ways > 0;

  /// Whether the run lands the ask.
  bool meets(int first, int last) {
    if (!Rules.validRun(first, last)) return false;
    final total = Rules.total(first, last);
    switch (kind) {
      case 'past':
        return total > Frac.of(mark);
      case 'halves':
        return total.d == BigInt.two;
      default:
        return total.isWhole;
    }
  }

  /// The taps the cheapest run takes from the opening.
  int? get fewest =>
      aim == null ? null : Rules.taps(aim!.$1, aim!.$2);

  /// The task, told in words for the ledger.
  String get task {
    switch (kind) {
      case 'past':
        return 'pour a run of casks that passes $mark '
            '${mark == 1 ? 'barrel' : 'barrels'}';
      case 'halves':
        return 'pour a run of casks that comes out in halves exactly';
      default:
        return 'pour a run of casks that comes to a whole barrel';
    }
  }
}
