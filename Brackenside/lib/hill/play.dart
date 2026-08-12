import 'hill.dart';
import 'rules.dart';

/// A hill being planted. Every state is a fresh value, and the
/// one before hangs on for take-back.
class Play {
  Play._(this.hill, this.rules, this.planted, this.moves, this.before);

  factory Play.of(Hill hill) {
    final rules = Rules(hill.side);
    return Play._(
      hill,
      rules,
      {
        ...rules.rim,
        for (final spot in rules.inner) spot: hill.opens,
      },
      0,
      null,
    );
  }

  /// A play stood at a planting, for the mark and the tests.
  factory Play.standing(Hill hill, Map<(int, int), String> planted) =>
      Play._(hill, Rules(hill.side), Map.of(planted), 0, null);

  final Hill hill;
  final Rules rules;

  /// Every spot's plant, rim and inside together.
  final Map<(int, int), String> planted;

  /// Replantings taken.
  final int moves;

  final Play? before;

  /// The line past which the hopeless hill admits it.
  static const gaveUpAt = 12;

  List<((int, int), (int, int), (int, int))> get rainbow =>
      rules.rainbow(planted);

  int get patches => rainbow.length;

  bool get isDone => patches == hill.asked;

  bool get gaveUp => !hill.winnable && moves >= gaveUpAt && !isDone;

  bool get isOver => isDone || gaveUp;

  /// Whether a spot is the player's to plant.
  bool canPlant((int, int) spot) => !rules.rim.containsKey(spot);

  /// Replants a spot with the next plant round: bracken, gorse,
  /// heather and round again.
  Play tapAt((int, int) spot) {
    if (isOver || !canPlant(spot)) return this;
    const round = ['A', 'B', 'C'];
    final next = Map.of(planted);
    next[spot] =
        round[(round.indexOf(planted[spot]!) + 1) % round.length];
    return Play._(hill, rules, next, moves + 1, this);
  }

  Play get back => before ?? this;

  /// A spot the sweep would replant towards the asking, with the
  /// plant it wants there; null when no planting lands it.
  ((int, int), String)? get next {
    final aim = rules.planting(hill.asked);
    if (aim == null || isDone) return null;
    for (final spot in rules.inner) {
      if (planted[spot] != aim[spot]) return (spot, aim[spot]!);
    }
    return null;
  }
}
