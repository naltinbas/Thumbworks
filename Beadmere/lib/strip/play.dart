import 'level.dart';
import 'levels.dart';
import 'rules.dart';

/// One go at an ask: the beads as they stand, the taps taken, and the
/// go before, so a bead can be turned back.
class Play {
  const Play._({
    required this.level,
    required this.strip,
    required this.moves,
    required this.seen,
    required this.before,
  });

  Play.of(this.level)
      : strip = const [],
        moves = 0,
        seen = const {},
        before = null;

  /// A go standing at a strip, no taps counted: what the mark draws.
  Play.standing(this.level, this.strip)
      : moves = 0,
        seen = const {},
        before = null;

  final Level level;

  /// The beads, light or dark. Empty means all light, which is how an
  /// ask opens.
  final List<int> strip;

  /// The taps taken.
  final int moves;

  /// The strips tried that had both repeats the ask wants.
  final Set<String> seen;

  final Play? before;

  /// The taps a hopeless ask runs to before the sham admits it.
  static const gaveUpAt = 16;

  /// The strips with both repeats a hopeless ask lets the player find
  /// before the sham admits it.
  static const enough = 3;

  /// The beads as a list, all light when nothing has been turned.
  List<int> get beads => strip.isEmpty
      ? [for (var i = 0; i < level.beads; i++) Rules.light]
      : strip;

  List<int> get periods => Rules.periodsOf(beads);

  bool get hasFirst => Rules.repeats(beads, level.first);

  bool get hasSecond => Rules.repeats(beads, level.second);

  bool get hasForced => Rules.repeats(beads, level.forced);

  /// Turns the bead at [which] over.
  Play turn(int which) {
    if (isOver || which < 0 || which >= level.beads) return this;
    final next = List.of(beads)
      ..[which] = beads[which] == Rules.light ? Rules.dark : Rules.light;
    final nowSeen = !level.winnable &&
            Rules.repeats(next, level.first) &&
            Rules.repeats(next, level.second)
        ? {...seen, next.join()}
        : seen;
    return Play._(
      level: level,
      strip: next,
      moves: moves + 1,
      seen: nowSeen,
      before: this,
    );
  }

  Play get back => before ?? this;

  bool get isDone => level.winnable && level.meets(beads);

  /// A hopeless ask, admitted: [enough] strips found with both repeats,
  /// or [gaveUpAt] taps gone.
  bool get gaveUp =>
      !level.winnable && (seen.length >= enough || moves >= gaveUpAt);

  bool get isOver => isDone || gaveUp;

  /// The bead the pointer names, the first that differs from the strip
  /// the sweep found; null when there is nothing to point at.
  int? get next {
    if (isOver || !level.winnable) return null;
    for (var i = 0; i < level.beads; i++) {
      if (beads[i] != level.aim[i]) return i;
    }
    return null;
  }

  /// The pointer's words.
  String pointed(int which) => beads[which] == Rules.light
      ? 'Turn bead ${which + 1} dark.'
      : 'Turn bead ${which + 1} light.';
}

/// Why two repeats force a third: the words behind the Why button.
String whyWords(Play play) {
  final level = play.level;
  final number = Levels.all.indexOf(level) + 1;
  return 'A strip of beads repeats every p when bead i and bead i and p '
      'along are the same colour, as far as the strip goes. A short strip can '
      'have several repeats that have nothing to do with one another. A long '
      'one cannot.\n\n'
      'Nathan Fine and Herbert Wilf showed in 1965 how long is long enough: a '
      'strip with repeats p and q that runs to p plus q less their greatest '
      'common divisor has that divisor as a repeat too, which for repeats '
      'with nothing in common means every bead is the same colour. The '
      'length is sharp. One bead shorter and there are strips with both '
      'repeats and not the divisor, and for repeats that are neighbouring '
      'Fibonacci numbers those strips are the Fibonacci strips themselves.\n\n'
      'The sham takes every strip of every length from two beads to twelve, '
      'reads off its repeats two ways, and holds every pair of them to the '
      'theorem.\n\n'
      'This is ask $number, ${level.name}. ${level.note}\n\n'
      'The counts in this note are the sweep\'s: every strip of beads, read '
      'in full before the sham was built.';
}
