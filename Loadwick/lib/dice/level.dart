import 'rules.dart';

/// One stall on the sham: which die the house rolls, or whether every
/// die must be beaten, and what the count found.
class Level {
  const Level({
    required this.name,
    required this.house,
    required this.ways,
    required this.picks,
    this.note,
  });

  final String name;

  /// The house's die, nought to three, or -1 when the pick must beat
  /// every other die.
  final int house;

  /// Picks that land, by the count; nought for the hopeless.
  final int ways;

  /// Picks to choose from, all of them.
  final int picks;

  /// One thing worth knowing about this stall, said by the why.
  final String? note;

  bool get winnable => ways > 0;

  Rules get rules => const Rules();

  /// The dice one may pick: every die but the house's, or all four.
  List<int> get choices => [for (var x = 0; x < 4; x++) if (x != house) x];

  /// Whether picking die [x] lands the ask.
  bool lands(int x) => house >= 0
      ? Rules.beats(Rules.dice[x], Rules.dice[house])
      : [for (var y = 0; y < 4; y++) if (y != x) y].every((y) => Rules.beats(Rules.dice[x], Rules.dice[y]));

  /// The task, told in words for the ledger.
  String get task => house >= 0
      ? 'pick a die that beats die ${Rules.names[house]} in more than half the thirty-six rolls'
      : 'pick a die that beats each of the other three in more than half the rolls';
}
