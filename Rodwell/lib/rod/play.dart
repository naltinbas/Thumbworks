import 'level.dart';
import 'levels.dart';
import 'rules.dart';

/// One go at an ask: where the rod is cut, the taps taken, and the go
/// before, so a cut can be taken back.
class Play {
  const Play._({
    required this.level,
    required this.cuts,
    required this.moves,
    required this.seen,
    required this.before,
  });

  Play.of(this.level)
      : cuts = const {},
        moves = 0,
        seen = const {},
        before = null;

  /// A go standing at a cutting, no taps counted: what the mark draws.
  Play.standing(this.level, this.cuts)
      : moves = 0,
        seen = const {},
        before = null;

  final Level level;

  /// Where the rod is cut, by the hand each cut follows.
  final Set<int> cuts;

  /// The taps taken.
  final int moves;

  /// The cuttings tried that reached the best the rod allows.
  final Set<String> seen;

  final Play? before;

  /// The taps a hopeless ask runs to before the sham admits it.
  static const gaveUpAt = 16;

  /// The best cuttings a hopeless ask lets the player find before the
  /// sham admits it.
  static const enough = 3;

  int get hands => level.hands;

  List<int> get parts => Rules.partsOf(hands, cuts);

  BigInt get product => Rules.product(parts);

  /// The best any cutting of this rod reaches.
  BigInt get best => Rules.bestByRule(hands);

  /// Cuts the rod after hand [place] + 1, or mends that cut.
  Play cut(int place) {
    if (isOver || place < 0 || place >= Rules.places(hands)) return this;
    final next = {...cuts};
    if (!next.remove(place)) next.add(place);
    final nowSeen =
        Rules.product(Rules.partsOf(hands, next)) == Rules.bestByRule(hands)
            ? {...seen, (next.toList()..sort()).join(',')}
            : seen;
    return Play._(
      level: level,
      cuts: next,
      moves: moves + 1,
      seen: nowSeen,
      before: this,
    );
  }

  Play get back => before ?? this;

  bool get isDone => level.winnable && level.meets(cuts);

  /// A hopeless ask, admitted: [enough] cuttings found that reach the
  /// best, or [gaveUpAt] taps gone.
  bool get gaveUp =>
      !level.winnable && (seen.length >= enough || moves >= gaveUpAt);

  bool get isOver => isDone || gaveUp;

  /// The cut the pointer names, the first place where this cutting
  /// differs from the best one; null when there is nothing to point at.
  int? get next {
    final aim = level.aim;
    if (aim == null || isOver) return null;
    for (var place = 0; place < Rules.places(hands); place++) {
      if (aim.contains(place) != cuts.contains(place)) return place;
    }
    return null;
  }

  /// The pointer's words.
  String pointed(int place) => cuts.contains(place)
      ? 'Mend the cut after hand ${place + 1}.'
      : 'Cut after hand ${place + 1}.';
}

/// Why the threes win: the words behind the Why button.
String whyWords(Play play) {
  final level = play.level;
  final number = Levels.all.indexOf(level) + 1;
  return 'A rod of so many hands, cut into whole parts, and the parts '
      'multiplied together. The ask is the biggest product the rod allows.\n\n'
      'Three things settle it, and each is a line of arithmetic. A part of '
      'five or more is better cut into a three and the rest, since three '
      'times what is left beats the part itself as soon as the part is five '
      'or more. A one is always wasted, since it multiplies nothing and the '
      'hand it takes would do more work inside another part. And three twos '
      'should be two threes, since nine beats eight. What is left after all '
      'that is threes, with a four or a single two over: all threes when the '
      'rod divides by three, threes and a four when one is left over, threes '
      'and a two when two are.\n\n'
      'It is the whole-number face of an older rule, that a fixed sum '
      'multiplies best when its parts are equal, with the best size being e '
      'if the parts could be any length at all. Three is the whole number '
      'nearest to it, which is why the threes win.\n\n'
      'This is ask $number, ${level.name}. ${level.note}\n\n'
      'The counts in this note are the sweep\'s: every cutting of every rod '
      'from two hands to twenty, tried in full before the sham was built.';
}
