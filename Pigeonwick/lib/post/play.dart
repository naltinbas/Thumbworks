import 'round.dart';
import 'rules.dart';

/// A round being posted. Every state is a fresh value, and the
/// one before hangs on for take-back.
class Play {
  Play._(this.round, this.rules, this.posting, this.held, this.moves,
      this.before);

  factory Play.of(Round round) => Play._(round, Rules(round.letters),
      List.filled(round.letters, -1), null, 0, null);

  /// A play stood at a posting, for the mark and the tests.
  factory Play.standing(Round round, List<int> posting) =>
      Play._(round, Rules(round.letters), List.of(posting), null,
          posting.where((hole) => hole >= 0).length, null);

  final Round round;
  final Rules rules;

  /// Each letter's hole, or -1 while it waits in the bag.
  final List<int> posting;

  /// The letter in the postman's hand, or null.
  final int? held;

  /// Postings and pull-backs taken, counted together.
  final int moves;

  final Play? before;

  /// The line past which the hopeless round admits it.
  static const gaveUpAt = 12;

  List<int> get homes => Rules.homes(posting);

  bool get allPosted => posting.every((hole) => hole >= 0);

  bool get isDone => allPosted && homes.length == round.home;

  bool get gaveUp => !round.winnable && moves >= gaveUpAt && !isDone;

  bool get isOver => isDone || gaveUp;

  /// Whether a hole already has a letter.
  int letterIn(int hole) => posting.indexOf(hole);

  /// Picks a letter up, from the bag or back out of its hole; or
  /// puts it down again.
  Play tapLetter(int letter) {
    if (isOver) return this;
    if (held == letter) {
      return Play._(round, rules, posting, null, moves, before);
    }
    return Play._(round, rules, posting, letter, moves, before);
  }

  /// Posts the held letter to a hole; a letter already there goes
  /// back to the bag.
  Play tapHole(int hole) {
    if (isOver) return this;
    final letter = held;
    if (letter == null) {
      // No letter in hand: pull back whatever sits here.
      final sitting = letterIn(hole);
      if (sitting < 0) return this;
      final next = List.of(posting);
      next[sitting] = -1;
      return Play._(round, rules, next, null, moves + 1, this);
    }
    final sitting = letterIn(hole);
    final next = List.of(posting);
    if (sitting >= 0 && sitting != letter) next[sitting] = -1;
    next[letter] = hole;
    return Play._(round, rules, next, null, moves + 1, this);
  }

  Play get back => before ?? this;

  /// The letter and hole the sweep would post next towards its
  /// round; null when none lands the asking.
  (int, int)? get next {
    final aim = rules.round(round.home);
    if (aim == null || isDone) return null;
    for (var letter = 0; letter < round.letters; letter++) {
      if (posting[letter] != aim[letter]) {
        return (letter, aim[letter]);
      }
    }
    return null;
  }
}
