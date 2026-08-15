import 'level.dart';
import 'levels.dart';
import 'rules.dart';

/// One go at an ask: the ballots drawn so far, in order, and the go
/// before, so a draw can be taken back.
class Play {
  const Play._({
    required this.level,
    required this.drawn,
    required this.moves,
    required this.before,
  });

  Play.of(this.level)
      : drawn = const [],
        moves = 0,
        before = null;

  /// A play stood at an order, for the mark and the tests.
  Play.standing(this.level, List<bool> order)
      : drawn = List.unmodifiable(order),
        moves = 0,
        before = null;

  final Level level;

  /// The ballots drawn so far: true for Ash, false for Birch.
  final List<bool> drawn;

  /// The draws taken.
  final int moves;

  final Play? before;

  /// The line past which the hopeless ask admits it, if the count is
  /// never completed.
  static const gaveUpAt = 30;

  int get ashDrawn => drawn.where((a) => a).length;
  int get birchDrawn => drawn.length - ashDrawn;
  int get ashLeft => level.ash - ashDrawn;
  int get birchLeft => level.birch - birchDrawn;

  bool get isComplete => drawn.length == level.ballots;

  List<int> get leads => Rules.leads(drawn);

  int get lead => leads.isEmpty ? 0 : leads.last;

  int get levelsSoFar => Rules.levels(drawn);
  int get changesSoFar => Rules.changesOfHands(drawn);
  bool get aheadSoFar => Rules.aheadThroughout(drawn);
  bool get neverBehindSoFar => Rules.neverBehind(drawn);

  /// Draws an Ash ballot ([ash] true) or a Birch one, if any are left.
  Play draw(bool ash) {
    if (isOver || (ash ? ashLeft : birchLeft) <= 0) return this;
    return Play._(level: level, drawn: [...drawn, ash], moves: moves + 1, before: this);
  }

  Play get back => before ?? this;

  bool get isDone => level.winnable && level.meets(drawn);

  /// A hopeless ask, admitted: the count is complete and the ask not
  /// met, as it never is, or [gaveUpAt] draws are taken.
  bool get gaveUp => !level.winnable && (isComplete || moves >= gaveUpAt);

  bool get isOver => isDone || gaveUp;

  /// What the pointer says: 0 draw Ash, 1 draw Birch, 2 take back; null
  /// when nothing points anywhere.
  int? get next {
    final aim = level.aim;
    if (aim == null || isOver) return null;
    for (var i = 0; i < drawn.length; i++) {
      if (drawn[i] != aim[i]) return 2;
    }
    if (drawn.length == aim.length) return null;
    return aim[drawn.length] ? 0 : 1;
  }

  static String pointed(int by) => switch (by) {
        0 => 'Draw an Ash ballot.',
        1 => 'Draw a Birch ballot.',
        _ => 'Take the last ballot back.',
      };
}

/// Why the majority over the poll: the words behind the Why button.
String whyWords(Play play) {
  final level = play.level;
  final number = Levels.all.indexOf(level) + 1;
  return 'Ash polls a ballots and Birch b, a more than b, and the ballots are '
      'drawn from the box one at a time. In how many of the orders is Ash '
      'ahead after every single ballot? Bertrand answered in 1887: the '
      'majority over the poll of them, (a - b)/(a + b) of the C(a+b, a) '
      'orders. The reflection says why: an order that keeps him ahead must '
      'start with an Ash ballot, and of the orders that start so, those that '
      'touch level later mirror one to one onto the orders that start with '
      'Birch, the count up to the first level swapped side for side; so the '
      'good orders are C(a+b-1, a-1) less C(a+b-1, a). Level allowed, the '
      'orders that never put him behind are (a - b + 1)/(a + 1) of the whole, '
      'and with a level poll those are Catalan\'s numbers.\n\n'
      'The game reads every order of every poll here through, ballot by '
      'ballot, and the sweep agrees with Bertrand and with the reflection on '
      'every poll to eight and eight.\n\n'
      'This is ask $number, ${level.name}. ${level.note}\n\n'
      'The tile\'s counts are the sweep\'s: every order of the poll asked, '
      'read through in full.';
}
