import 'level.dart';
import 'levels.dart';
import 'rules.dart';

/// One go at an ask: the three bends on their dials, the taps taken,
/// the whole settings tried, and the go before, so a tap can be taken
/// back.
class Play {
  const Play._({
    required this.level,
    required this.bends,
    required this.moves,
    required this.seen,
    required this.before,
  });

  Play.of(this.level)
      : bends = const [1, 1, 1],
        moves = 0,
        seen = const {},
        before = null;

  /// A go standing at three bends, no taps counted: what the mark draws.
  Play.standing(this.level, this.bends)
      : moves = 0,
        seen = const {},
        before = null;

  final Level level;

  /// The three bends, on the dials.
  final List<int> bends;

  /// The taps taken.
  final int moves;

  /// The settings with whole fourths seen.
  final Set<String> seen;

  final Play? before;

  /// The taps a hopeless ask runs to before the sham admits it, if the
  /// player never finds three whole settings.
  static const gaveUpAt = 12;

  /// The whole settings a hopeless ask lets the player find before the
  /// sham admits it.
  static const enough = 3;

  int get sum => Rules.sum(bends);
  int get pairs => Rules.pairs(bends);
  bool get whole => Rules.whole(bends);
  (int, int)? get fourths => Rules.fourths(bends);
  int get outerSign => Rules.outerSign(bends);
  String get inner => Rules.tellFourth(bends, inner: true);
  String get outer => Rules.tellFourth(bends, inner: false);

  /// The whole fourths by trial, the second voice.
  List<int> get fourthsByTrial => Rules.fourthsByTrial(bends);

  /// Steps the dial at [place] by [by], within the dials' range.
  Play step(int place, int by) {
    if (isOver || place < 0 || place > 2 || by == 0) return this;
    final next = List.of(bends)..[place] = bends[place] + by;
    if (!Rules.valid(next)) return this;
    final nowSeen = Rules.whole(next) ? {...seen, next.join(',')} : seen;
    return Play._(level: level, bends: next, moves: moves + 1, seen: nowSeen, before: this);
  }

  Play get back => before ?? this;

  bool get isDone => level.winnable && level.meets(bends);

  /// A hopeless ask, admitted: [enough] whole settings seen, each with
  /// its two fourths apart, or [gaveUpAt] taps gone.
  bool get gaveUp => !level.winnable && (seen.length >= enough && whole || moves >= gaveUpAt);

  bool get isOver => isDone || gaveUp;

  /// What the pointer says: (place, by), the first dial off the aim
  /// stepped towards it; null when there is nothing to point at.
  (int, int)? get next {
    final aim = level.aim;
    if (aim == null || isOver) return null;
    for (var i = 0; i < 3; i++) {
      if (bends[i] != aim[i]) return (i, aim[i] > bends[i] ? 1 : -1);
    }
    return null;
  }

  /// The pointer's words.
  static String pointed((int, int) aim) => 'Step bend ${aim.$1 + 1} ${aim.$2 > 0 ? 'up' : 'down'}.';
}

/// Why the two fourths are never twins: the words behind the Why
/// button.
String whyWords(Play play) {
  final level = play.level;
  final number = Levels.all.indexOf(level) + 1;
  return 'Three bubbles kissing, each touching the other two, and there are '
      'always two more that kiss all three, one in the gap between them and '
      'one round the outside. Call a bubble\'s bend one over its radius. '
      'Descartes found in 1643, writing to Princess Elisabeth of Bohemia, '
      'that the four bends of four bubbles kissing satisfy (a + b + c + d) '
      'squared equals twice the sum of their squares, so the fourth bend is '
      'a + b + c give or take twice the root of ab + bc + ca: the plus for the '
      'bubble in the gap, the minus for the outer one, whose bend counts '
      'negative when it wraps round the three, nought when it flattens to a '
      'straight line, and positive when it sits in the far gap. Soddy set it '
      'to verse in 1936, the kiss precise. The two fourths are of one bend '
      'only when the root is nought, which three bends above nought never '
      'give.\n\n'
      'The game takes every setting of the three dials, bends 1 to 20, 8,000 '
      'settings, works the two fourth bends by the formula, and tries every '
      'whole bend from -60 to 180 against Descartes\' relation itself: the '
      'whole fourths the trial finds are exactly the formula\'s on all 8,000, '
      'both whole on 207 settings, the outer wrapping round on 7,001, flat '
      'on 33 and in the far gap on 966, and the two fourths apart on every '
      'one.\n\n'
      'This is ask $number, ${level.name}. ${level.note}\n\n'
      'The tile\'s counts are the sweep\'s: every setting of the dials, '
      'worked in full.';
}
