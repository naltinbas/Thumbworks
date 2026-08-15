import 'level.dart';
import 'levels.dart';
import 'rules.dart';

/// One go at an ask: the yard as it stands, the shunts taken, and the go
/// before, so a shunt can be taken back.
class Play {
  const Play._({
    required this.level,
    required this.yard,
    required this.moves,
    required this.before,
  });

  Play.of(this.level)
      : yard = level.start,
        moves = 0,
        before = null;

  /// A play stood at an arrangement, for the mark and the tests.
  Play.standing(this.level, this.yard)
      : moves = 0,
        before = null;

  final Level level;

  /// The wagons as they stand, the gap as 0.
  final List<int> yard;

  /// The shunts taken.
  final int moves;

  final Play? before;

  /// The line past which the hopeless ask admits it.
  static const gaveUpAt = 40;

  int get gap => yard.indexOf(0);

  /// The fewest shunts home from here, or null when there is no way.
  int? get fewest => Rules.fewest(yard);

  int get inversions => Rules.inversions(yard);

  /// Shunts the wagon at berth [from] into the gap, if it lies beside it.
  Play tap(int from) {
    if (isOver || from < 0 || from > 8) return this;
    final next = Rules.shunt(yard, from);
    if (next == null) return this;
    return Play._(level: level, yard: next, moves: moves + 1, before: this);
  }

  Play get back => before ?? this;

  bool get isHome => level.meets(yard);

  bool get isDone => level.winnable && isHome;

  /// A hopeless ask, admitted after [gaveUpAt] shunts.
  bool get gaveUp => !level.winnable && moves >= gaveUpAt;

  bool get isOver => isDone || gaveUp;

  /// The berth the pointer rings: the next shunt on a shortest way home,
  /// or null.
  int? get next => isOver ? null : Rules.next(yard);

  static String pointed(int berth) => 'Shunt the ringed wagon, ${Rules.home[berth] == 0 ? 'the one at the bottom right' : 'berth ${berth + 1}'}.';
}

/// Why the shunts, and why the swapped pair never comes home: the words
/// behind the Why button.
String whyWords(Play play) {
  final level = play.level;
  final number = Levels.all.indexOf(level) + 1;
  return 'Eight wagons and one empty berth on a three-by-three yard, and the '
      'only move a shunt: a wagon beside the gap slides into it. Count the '
      'pairs of wagons out of order, reading the yard row by row: a sideways '
      'shunt changes nothing in that order, and an up-or-down shunt jumps one '
      'wagon over the two between it and the gap, changing the count by two '
      'or by nought. So the count stays even or stays odd, whatever is '
      'shunted; home has nought pairs out of order, and only the yards with '
      'an even count can ever get there. Sam Loyd offered a thousand dollars '
      'for the yard with two wagons swapped, and never paid.\n\n'
      'The game walks out from home through every yard the shunts can reach, '
      'breadth first, and finds 181,440 of the 362,880 arrangements, the '
      'fewest shunts to each of them, and 31 the most any needs; and the '
      'count of pairs out of order is even on exactly those 181,440 and odd '
      'on the rest.\n\n'
      'This is ask $number, ${level.name}. ${level.note}\n\n'
      'The tile\'s fewest is the walk\'s: the shortest way home, found from '
      'home outward.';
}
