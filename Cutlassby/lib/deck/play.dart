import 'level.dart';
import 'rules.dart';

/// A crew being paid. Every state is a fresh value, and the one before
/// hangs on for take-back.
class Play {
  Play._(this.level, this.rules, this.shares, this.voted, this.moves, this.before);

  factory Play.of(Level level) => Play._(level, level.rules, [Level.gold, ...List.filled(level.pirates - 1, 0)], false, 0, null);

  /// A play stood at a plan, voted, for the mark and the tests.
  factory Play.standing(Level level, List<int> shares) =>
      Play._(level, level.rules, List.of(shares), true, Level.gold - shares[0], null);

  final Level level;
  final Rules rules;

  /// Each pirate's coins, the captain first.
  final List<int> shares;

  /// Whether the plan has been put to the vote.
  final bool voted;

  /// Coins given, counted.
  final int moves;

  final Play? before;

  int get kept => shares[0];

  int get given => Level.gold - kept;

  int get pirates => level.pirates;

  List<bool> get votes => rules.votes(shares);

  int get ayes => rules.ayes(shares);

  int get needed => rules.needed(pirates);

  bool get passes => rules.passes(shares);

  /// What each pirate but the captain expects with the captain gone.
  List<int> get expects => rules.expects(pirates);

  bool get isDone => voted && passes && kept >= level.keep;

  /// Voted and lost, or passed keeping too little, on a crew that could
  /// have paid.
  bool get missed => level.winnable && voted && !isDone;

  bool get gaveUp => !level.winnable && voted;

  bool get isOver => voted;

  /// Gives pirate [i] a coin from the captain's pile.
  Play give(int i) {
    if (voted || i < 1 || i >= pirates || kept == 0) return this;
    final next = [for (var k = 0; k < pirates; k++) k == 0 ? shares[0] - 1 : k == i ? shares[i] + 1 : shares[k]];
    return Play._(level, rules, next, false, moves + 1, this);
  }

  /// Puts the plan to the vote.
  Play get vote => voted ? this : Play._(level, rules, shares, true, moves, this);

  Play get back => before ?? this;

  /// What the show-me points at: ('give', pirate) for the first pirate
  /// short of the best plan, ('take', pirate) for one over it, or
  /// ('vote', 0) when the plan is the best plan; null when nothing lands.
  (String, int)? get next {
    if (isOver || !level.winnable) return null;
    final aim = aimFor(level);
    for (var i = 1; i < pirates; i++) {
      if (shares[i] > aim[i]) return ('take', i);
    }
    for (var i = 1; i < pirates; i++) {
      if (shares[i] < aim[i]) return ('give', i);
    }
    return ('vote', 0);
  }

  /// The best plan for the crew, kept once found.
  static List<int> aimFor(Level level) => level.rules.best(level.pirates);
}
