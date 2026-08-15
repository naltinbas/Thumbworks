import 'rules.dart';

/// One ask: a count of turns to make, round one side of the hoop.
class Level {
  const Level({
    required this.name,
    required this.inside,
    required this.want,
    required this.ways,
    required this.aim,
    required this.note,
  });

  final String name;

  /// Which side of the hoop the roll goes round.
  final bool inside;

  /// The turns a trip must make, as a fraction in lowest terms.
  final (int, int) want;

  /// How many of the settings land it, from the sweep.
  final int ways;

  /// The setting the pointer walks to, (hoop, roller), or null when none
  /// lands it.
  final (int, int)? aim;

  /// Something worth knowing, computed.
  final String note;

  bool get winnable => ways > 0;

  /// Whether the setting lands the ask.
  bool meets(int hoop, int coin, bool side) => side == inside && Rules.turns(hoop, coin, side) == want;

  /// The task, told in words for the ledger.
  String get task => 'set the hoop and the roller so the roller turns ${_exactly()} going round the ${inside ? 'inside' : 'outside'}';

  String _exactly() {
    if (want == (1, 1)) return 'exactly once';
    if (want == (2, 1)) return 'exactly twice';
    if (want == (3, 1)) return 'exactly three times';
    if (want == (3, 2)) return 'exactly one and a half times';
    return 'exactly ${Rules.turnsTold(want)}';
  }
}
