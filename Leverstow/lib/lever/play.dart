import 'frac.dart';
import 'level.dart';
import 'levels.dart';
import 'rules.dart';

/// One go at an ask: the loop as it stands, the taps taken, the
/// one-lever loops tried, and the go before, so a tap can be taken
/// back.
class Play {
  const Play._({
    required this.level,
    required this.loop,
    required this.moves,
    required this.seen,
    required this.before,
  });

  /// The opening loop is one lever on its own, so it counts as one of
  /// the levers tried alone from the start.
  Play.of(this.level)
      : loop = Rules.opening,
        moves = 0,
        seen = const {'A'},
        before = null;

  /// A go standing at a loop, no taps counted: what the mark draws.
  Play.standing(this.level, this.loop)
      : moves = 0,
        seen = const {},
        before = null;

  final Level level;

  /// The loop of levers, one letter to a slot.
  final String loop;

  /// The taps taken.
  final int moves;

  /// The levers that have been run on their own.
  final Set<String> seen;

  final Play? before;

  /// The taps a hopeless ask runs to before the sham admits it.
  static const gaveUpAt = 12;

  /// How many levers have to be tried on their own before the sham
  /// admits it.
  static const enough = 2;

  /// How many rounds the purse is drawn over.
  static const rounds = 40;

  /// What the purse gains a round, once the machine has settled.
  Frac get climb => Rules.climb(loop);

  /// The purse after each round, from empty.
  List<Frac> get purse => Rules.purse(loop, rounds);

  /// The share of turns of the loop that start on each remainder.
  List<Frac> get resting => Rules.resting(loop);

  Play _to(String next) {
    final nowSeen =
        Rules.oneLever(next) ? {...seen, next[0]} : seen;
    return Play._(
      level: level,
      loop: next,
      moves: moves + 1,
      seen: nowSeen,
      before: this,
    );
  }

  /// Turns the lever in slot [slot] over.
  Play flip(int slot) {
    if (isOver || slot < 0 || slot >= loop.length) return this;
    final was = loop[slot];
    return _to(loop.replaceRange(slot, slot + 1, was == 'A' ? 'B' : 'A'));
  }

  /// Adds a slot at the end, holding the plain lever.
  Play get longer =>
      isOver || loop.length >= Rules.most ? this : _to('${loop}A');

  /// Takes the last slot away.
  Play get shorter => isOver || loop.length <= Rules.least
      ? this
      : _to(loop.substring(0, loop.length - 1));

  Play get back => before ?? this;

  bool get isDone => level.winnable && level.meets(loop);

  /// A hopeless ask, admitted: both levers run on their own, or
  /// [gaveUpAt] taps gone.
  bool get gaveUp =>
      !level.winnable && (seen.length >= enough || moves >= gaveUpAt);

  bool get isOver => isDone || gaveUp;

  /// What the pointer says: ('add', 0), ('drop', 0) or ('flip', slot),
  /// the next tap on the cheapest way to the ask; null when there is
  /// nothing to point at.
  (String, int)? get next {
    if (isOver || !level.winnable) return null;
    final aim = level.aim;
    if (loop.length > aim.length) return ('drop', 0);
    if (loop.length < aim.length) return ('add', 0);
    for (var i = 0; i < aim.length; i++) {
      if (loop[i] != aim[i]) return ('flip', i);
    }
    return null;
  }

  /// How many taps the ask is still away.
  int? get away => level.winnable ? Rules.cost(loop, level.aim) : null;

  /// The pointer's words.
  static String pointed((String, int) aim) {
    switch (aim.$1) {
      case 'add':
        return 'Put another slot on the loop.';
      case 'drop':
        return 'Take the last slot off the loop.';
      default:
        return 'Turn the lever in slot ${aim.$2 + 1} over.';
    }
  }
}

/// Why two fair levers climb: the words behind the Why button.
String whyWords(Play play) {
  final level = play.level;
  final number = Levels.all.indexOf(level) + 1;
  return 'Lever A is a plain coin, a coin won one time in two and a coin '
      'lost the rest. Lever B looks at the purse first: when three divides '
      'it B pays only one time in ten, and otherwise three times in four. B '
      'is fair too, though it takes a little work to see. Left to itself it '
      'settles on the remainders 0, 1 and 2 in the shares 5/13, 2/13 and '
      '6/13, so it stands on a multiple of three five times in thirteen and '
      'loses four fifths of a coin there, and the other eight times it '
      'gains half a coin: 5 times 4/5 is 4, and 8 times 1/2 is 4.\n\n'
      'Run the two in a loop, though, and the purse climbs. The loop keeps '
      'the purse off multiples of three more often than B on its own does, '
      'so B is pulled at its kind odds more often than its mean ones. A '
      'once and B twice gains 2416/35601 of a coin a round. Juan Parrondo '
      'put the paradox in 1996, and Harmer and Abbott wrote it up in Nature '
      'in 1999.\n\n'
      'The sham takes every loop of twelve slots or fewer, 8,190 of them, '
      'and solves each one twice, once on three remainders and once on the '
      'long chain of remainder and slot. Of those, 8,154 climb, 36 stand '
      'still and none sinks.\n\n'
      'This is ask $number, ${level.name}. ${level.note}\n\n'
      'The counts on the card at the end are the sweep\'s: every loop of '
      'levers, run in full.';
}
