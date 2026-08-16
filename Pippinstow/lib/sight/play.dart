import 'level.dart';
import 'levels.dart';
import 'rules.dart';

/// One go at an ask: the tree picked, the taps taken, the edge trees
/// tried, and the go before, so a tap can be taken back.
class Play {
  const Play._({
    required this.level,
    required this.picked,
    required this.moves,
    required this.edgeTries,
    required this.before,
  });

  Play.of(this.level)
      : picked = null,
        moves = 0,
        edgeTries = 0,
        before = null;

  /// A go standing at a tree, no taps counted: what the mark draws.
  Play.standing(this.level, this.picked)
      : moves = 0,
        edgeTries = 0,
        before = null;

  final Level level;

  /// The tree picked, or null.
  final (int, int)? picked;

  /// The taps taken.
  final int moves;

  /// How many taps landed on a tree of the first row or the first file.
  final int edgeTries;

  final Play? before;

  /// The taps a hopeless ask runs to before the sham admits it, if the
  /// player never tries the edges.
  static const gaveUpAt = 12;

  /// The edge trees a hopeless ask lets the player try before the sham
  /// admits it.
  static const enough = 3;

  bool get seen => picked != null && Rules.seenByFactor(picked!);

  /// The trees between the gate and the picked tree.
  List<(int, int)> get between => picked == null ? const [] : Rules.between(picked!);

  /// The trees the picked tree hides.
  List<(int, int)> get hides => picked == null ? const [] : Rules.hides(picked!);

  (int, int)? get front => picked == null ? null : Rules.front(picked!);

  bool get onEdge => picked != null && (picked!.$1 == 1 || picked!.$2 == 1);

  /// A tap on tree [t]: picks it, or unpicks it when it is the one
  /// picked.
  Play tap((int, int) t) {
    if (isOver || !Rules.inOrchard(t)) return this;
    final next = picked == t ? null : t;
    final edge = next != null && (next.$1 == 1 || next.$2 == 1);
    return Play._(level: level, picked: next, moves: moves + 1, edgeTries: edgeTries + (edge ? 1 : 0), before: this);
  }

  Play get back => before ?? this;

  bool get isDone => level.winnable && picked != null && level.meets(picked!);

  /// A hopeless ask, admitted: [enough] edge trees tried, each in sight,
  /// or [gaveUpAt] taps gone.
  bool get gaveUp => !level.winnable && (edgeTries >= enough && onEdge || moves >= gaveUpAt);

  bool get isOver => isDone || gaveUp;

  /// What the pointer says: the tree to tap, the aim; null when there
  /// is nothing to point at.
  (int, int)? get next {
    final aim = level.aim;
    if (aim == null || isOver || picked == aim) return null;
    return aim;
  }

  /// The pointer's words.
  static String pointed((int, int) aim) => 'Tap the tree at ${Rules.tell(aim)}.';
}

/// Why the edge is always in sight: the words behind the Why button.
String whyWords(Play play) {
  final level = play.level;
  final number = Levels.all.indexOf(level) + 1;
  return 'An orchard of ten rows and ten files, a tree at every crossing, and '
      'a watcher at the gate, one step outside the first tree of all. A tree '
      'is in sight when no other tree stands on the straight line to it, and '
      'hidden when one does. Number the trees by file and row from the gate: '
      'the tree at (a, b) is in sight exactly when a and b share no factor, '
      'since a tree at (c, d) stands on the line to it exactly when a d is '
      'b c with c and d smaller, which is a common factor at work; and a tree '
      'in sight hides its multiples, (2a, 2b), (3a, 3b) and on. This is '
      'Euclid\'s orchard, and the trees in sight thin out as the orchard '
      'grows, towards six in ten by Cesaro\'s count, though here, to ten '
      'rows, they are 63 in a hundred.\n\n'
      'The game takes every tree of the hundred and asks two ways whether it '
      'is in sight, once by the factor of its file and row and once by '
      'looking along the line for a tree in the way, and the two agree on all '
      'a hundred: 63 in sight and 37 hidden, and every tree on the two edges '
      'in sight.\n\n'
      'This is ask $number, ${level.name}. ${level.note}\n\n'
      'The tile\'s counts are the sweep\'s: every tree of the orchard, looked '
      'at in full.';
}
