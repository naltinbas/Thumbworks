import 'rules.dart';

/// One ask: how many stones of each colour, and how many lamps they are
/// to leave lit.
class Level {
  const Level({
    required this.name,
    required this.dark,
    required this.pale,
    required this.lit,
    required this.ways,
    required this.fewest,
    required this.note,
  });

  final String name;

  /// How many dark stones the ask calls for.
  final int dark;

  /// How many pale stones.
  final int pale;

  /// How many lamps are to be left lit.
  final int lit;

  /// How many boards land it. The sweep's number, and the checker
  /// refuses the bake if it drifts.
  final int ways;

  /// The taps from the opening to the nearest board that lands it; null
  /// when none does.
  final int? fewest;

  /// Something worth knowing, written out by hand.
  final String note;

  /// How many boards have these two stone counts at all.
  int get boards {
    int choose(int n, int k) {
      var out = 1;
      for (var i = 0; i < k; i++) {
        out = out * (n - i) ~/ (i + 1);
      }
      return out;
    }

    return choose(Rules.holes, dark) * choose(Rules.holes, pale);
  }

  /// The fewest lamps these stone counts can ever leave.
  int get floor => Rules.floor(dark, pale);

  bool get winnable => ways > 0;

  /// Whether this board lands the ask.
  bool meets((int, int) board) =>
      Rules.count(board.$1) == dark &&
      Rules.count(board.$2) == pale &&
      Rules.count(Rules.lamps(board.$1, board.$2)) == lit;

  /// The task, told in words.
  String get task =>
      'lay $dark dark stones and $pale pale so that $lit '
      '${lit == 1 ? 'lamp lights' : 'lamps light'}';
}
