import 'level.dart';
import 'levels.dart';
import 'rules.dart';

/// One go at an ask: the trios picked, the taps taken, the families of
/// eleven or more tried, and the go before, so a tap can be taken back.
class Play {
  const Play._({
    required this.level,
    required this.family,
    required this.moves,
    required this.seen,
    required this.before,
  });

  Play.of(this.level)
      : family = 0,
        moves = 0,
        seen = const {},
        before = null;

  /// A go standing at a family, no taps counted: what the mark draws.
  Play.standing(this.level, this.family)
      : moves = 0,
        seen = const {},
        before = null;

  final Level level;

  /// The trios picked, as a mask.
  final int family;

  /// The taps taken.
  final int moves;

  /// The families of eleven trios or more seen.
  final Set<int> seen;

  final Play? before;

  /// The taps a hopeless ask runs to before the sham admits it, if the
  /// player never picks eleven.
  static const gaveUpAt = 30;

  /// The families of eleven the hopeless ask lets the player pick before
  /// the sham admits it.
  static const enough = 3;

  int get size => Rules.size(family);

  List<int> get picked => Rules.triosOf(family);

  /// The pairs of picked trios that share no friend.
  List<(int, int)> get apart => Rules.apart(family);

  bool get sharing => apart.isEmpty;

  /// Whether one of each missing pair at most is picked, the second
  /// voice.
  bool get oneOfEachPair => Rules.oneOfEachPair(family);

  List<int> get hands => Rules.hands(family);

  int? get star => Rules.star(family);

  /// A tap on trio [trio]: picks it or unpicks it.
  Play tap(int trio) {
    if (isOver || Rules.placeOf(trio) < 0) return this;
    final next = Rules.toggled(family, trio);
    final nowSeen = Rules.size(next) >= 11 ? {...seen, next} : seen;
    return Play._(level: level, family: next, moves: moves + 1, seen: nowSeen, before: this);
  }

  Play get back => before ?? this;

  bool get isDone => level.winnable && level.meets(family);

  /// A hopeless ask, admitted: [enough] families of eleven have been
  /// picked, each with its pairs apart, or [gaveUpAt] taps are gone.
  bool get gaveUp => !level.winnable && (seen.length >= enough && size >= 11 || moves >= gaveUpAt);

  bool get isOver => isDone || gaveUp;

  /// What the pointer says: (trio, unpick), a picked trio off the aim
  /// unpicked first, then the aim's next trio picked; null when there
  /// is nothing to point at.
  (int, bool)? get next {
    final aim = level.aim;
    if (aim == null || isOver) return null;
    for (final t in picked) {
      if (!Rules.picked(aim, t)) return (t, true);
    }
    for (final t in Rules.triosOf(aim)) {
      if (!Rules.picked(family, t)) return (t, false);
    }
    return null;
  }

  /// The pointer's words.
  static String pointed((int, bool) aim) => '${aim.$2 ? 'Unpick' : 'Pick'} ${Rules.nameOf(aim.$1)}.';
}

/// Why ten is the most: the words behind the Why button.
String whyWords(Play play) {
  final level = play.level;
  final number = Levels.all.indexOf(level) + 1;
  return 'Six friends, and the twenty trios among them. Pick trios so that '
      'every two share a friend, and you will stop at ten: two trios of six '
      'friends miss each other only when one is the other three, so the '
      'twenty trios fall into ten missing pairs, and a sharing family takes '
      'one of each pair at most. Erdos, Ko and Rado proved the general law '
      'in 1961: among the k-sets of n things, n at least 2k, a family in '
      'which every two meet has at most as many sets as hold one fixed thing, '
      'the star, and for n above 2k the star is the only family that large. '
      'Here n is twice k, and the stars are six of 1,024 families as large.\n\n'
      'The game takes every family of the twenty trios, 1,048,576, looks at '
      'every pair of trios in each for a shared friend, and again asks only '
      'whether the family takes both trios of any missing pair; the two agree '
      'on all 1,048,576, and 59,049 families share throughout, three to the '
      'ten, 1,024 of them ten trios and none eleven.\n\n'
      'This is ask $number, ${level.name}. ${level.note}\n\n'
      'The tile\'s counts are the sweep\'s: every family of the twenty trios, '
      'looked at in full.';
}
