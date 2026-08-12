import 'rules.dart';
import 'village.dart';

/// A village being settled. Every state is a fresh value, and the
/// one before hangs on for take-back.
class Play {
  Play._(this.village, this.rules, this.pounds, this.moves, this.before);

  factory Play.of(Village village) => Play._(
        village,
        Rules(village.houses, village.roads),
        List.of(village.spread),
        0,
        null,
      );

  final Village village;
  final Rules rules;

  /// The pounds each house holds as things stand.
  final List<int> pounds;

  /// Moves taken.
  final int moves;

  final Play? before;

  /// The line past which the hopeless village admits it.
  static const gaveUpAt = 12;

  bool get isDone => rules.settled(pounds);

  bool get gaveUp =>
      !village.winnable && moves >= gaveUpAt && !isDone;

  bool get isOver => isDone || gaveUp;

  Play _moved(List<int> after) =>
      Play._(village, rules, after, moves + 1, this);

  /// [house] sends a pound down each of its roads.
  Play lendAt(int house) =>
      isOver ? this : _moved(rules.lend(pounds, house));

  /// [house] pulls a pound up each of its roads.
  Play borrowAt(int house) =>
      isOver ? this : _moved(rules.borrow(pounds, house));

  Play get back => before ?? this;

  /// The search's step towards a fewest settlement: the house and
  /// whether it lends; null when none is in reach.
  (int, bool)? get next => rules.firstMove(pounds);
}
