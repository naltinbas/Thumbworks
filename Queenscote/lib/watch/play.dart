import 'level.dart';
import 'levels.dart';
import 'rules.dart';

/// What the show-me points at.
enum Aim { set, lift }

/// A board being watched. Every state is a fresh value, and the one
/// before hangs on for take-back.
class Play {
  const Play._({
    required this.level,
    required this.placed,
    required this.moves,
    required this.before,
  });

  Play.of(this.level)
      : placed = const [],
        moves = 0,
        before = null;

  /// A play stood at a placing, for the mark and the tests.
  Play.standing(this.level, List<int> squares)
      : placed = List.unmodifiable(squares),
        moves = 0,
        before = null;

  final Level level;

  /// The squares the queens stand on, in the order set.
  final List<int> placed;

  /// Settings and liftings taken, counted together.
  final int moves;

  final Play? before;

  /// The line past which the hopeless ask admits it, if the queen never
  /// stands on a middle square.
  static const gaveUpAt = 20;

  int get unseen => Rules.unseen(level.side, placed);

  bool get isFull => placed.length == level.queens;

  /// The mask of squares seen.
  int get seen => Rules.seen(level.side, placed);

  bool isSeen(int square) => seen & (1 << square) != 0;

  /// Taps a square: a queen there is lifted; a bare square gets a queen
  /// if any are left to set.
  Play tap(int square) {
    if (isOver || square < 0 || square >= level.squares) return this;
    if (placed.contains(square)) {
      return Play._(level: level, placed: [for (final q in placed) if (q != square) q], moves: moves + 1, before: this);
    }
    if (isFull) return this;
    return Play._(level: level, placed: [...placed, square], moves: moves + 1, before: this);
  }

  Play get back => before ?? this;

  bool get isDone => level.winnable && level.meets(placed);

  /// A hopeless ask, admitted: the lone queen stands on a middle square,
  /// seeing 12 and leaving 4, the nearest there is; or [gaveUpAt] taps.
  bool get gaveUp => !level.winnable && (isFull && unseen == 4 || moves >= gaveUpAt);

  bool get isOver => isDone || gaveUp;

  /// What the pointer says: lift a queen not in the aim, else set the
  /// aim's next; null when nothing points anywhere.
  (Aim, int)? get next {
    final aim = level.aim;
    if (aim == null || isOver) return null;
    for (final q in placed) {
      if (!aim.contains(q)) return (Aim.lift, q);
    }
    for (final q in aim) {
      if (!placed.contains(q)) return (Aim.set, q);
    }
    return null;
  }

  static String pointed((Aim, int) aim, int side) => aim.$1 == Aim.lift ? 'Lift the queen at ${Rules.told(side, aim.$2)}.' : 'Set a queen at ${Rules.told(side, aim.$2)}.';
}

/// Why five and never four: the words behind the Why button.
String whyWords(Play play) {
  final level = play.level;
  final number = Levels.all.indexOf(level) + 1;
  return 'A queen sees her own square and every square along her row, her '
      'column and her two slants. How few queens see every square of a board? '
      'Two for the four by four, three for the five and the six, four for the '
      'seven, and five for the chessboard: five watch it in 4,860 ways, and '
      'four never, every one of their 635,376 placings leaving a square '
      'unseen and the best of them two. There is no short reason for the four; '
      'the sweep is the reason, and it is done twice over.\n\n'
      'The game tries every placing of the queens asked as masks of squares '
      'seen, and finds every watching set again by picking a queen for the '
      'first unseen square in turn, and the two counts agree on every board '
      'here.\n\n'
      'This is ask $number, ${level.name}. ${level.note}\n\n'
      'The tile\'s counts are the sweep\'s: every placing of the queens asked '
      'on the board asked, tried in full.';
}
