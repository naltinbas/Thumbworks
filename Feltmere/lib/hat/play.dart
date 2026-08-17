import 'level.dart';
import 'levels.dart';
import 'rules.dart';

/// One go at an ask: the agreement as it stands, the taps taken, and
/// the go before, so a tap can be taken back.
class Play {
  const Play._({
    required this.level,
    required this.agreement,
    required this.moves,
    required this.seen,
    required this.before,
  });

  Play.of(this.level)
      : agreement = const [
          [2, 2, 2, 2],
          [2, 2, 2, 2],
          [2, 2, 2, 2],
        ],
        moves = 0,
        seen = const {},
        before = null;

  /// A go standing at an agreement, no taps counted: what the mark
  /// draws.
  Play.standing(this.level, this.agreement)
      : moves = 0,
        seen = const {},
        before = null;

  final Level level;

  /// What each villager is to say for each sight.
  final List<List<int>> agreement;

  /// The taps taken.
  final int moves;

  /// The agreements tried that won as many hattings as any agreement
  /// can.
  final Set<String> seen;

  final Play? before;

  /// The taps a hopeless ask runs to before the sham admits it.
  static const gaveUpAt = 24;

  /// The best-there-is agreements a hopeless ask lets the player find
  /// before the sham admits it.
  static const enough = 2;

  /// The most hattings any agreement wins.
  static const best = 6;

  int get wins => Rules.wins(agreement);

  List<String> get losses => Rules.losses(agreement);

  /// How many words the agreement calls for, and how many of them come
  /// out wrong over the eight hattings.
  int get words => Rules.words(agreement);

  int get wrongs => Rules.wrongs(agreement);

  /// Turns the cell for villager [who] on sight [sight] round: quiet,
  /// black, white and back again.
  Play turn(int who, int sight) {
    if (isOver ||
        who < 0 ||
        who >= Rules.villagers ||
        sight < 0 ||
        sight >= Rules.sights.length) {
      return this;
    }
    final next = [
      for (var i = 0; i < Rules.villagers; i++) List.of(agreement[i]),
    ];
    next[who][sight] = switch (agreement[who][sight]) {
      Rules.quiet => Rules.black,
      Rules.black => Rules.white,
      _ => Rules.quiet,
    };
    final nowSeen = Rules.wins(next) == best
        ? {...seen, next.map((rule) => rule.join()).join('|')}
        : seen;
    return Play._(
      level: level,
      agreement: next,
      moves: moves + 1,
      seen: nowSeen,
      before: this,
    );
  }

  Play get back => before ?? this;

  bool get isDone => level.winnable && level.meets(agreement);

  /// A hopeless ask, admitted: [enough] agreements found that win as
  /// many hattings as any can, or [gaveUpAt] taps gone.
  bool get gaveUp =>
      !level.winnable && (seen.length >= enough || moves >= gaveUpAt);

  bool get isOver => isDone || gaveUp;

  /// What the pointer says: (villager, sight), the first cell that
  /// differs from the cheapest agreement the sweep found; null when
  /// there is nothing to point at.
  (int, int)? get next {
    if (isOver || !level.winnable) return null;
    for (var who = 0; who < Rules.villagers; who++) {
      for (var sight = 0; sight < Rules.sights.length; sight++) {
        if (agreement[who][sight] != level.aim[who][sight]) return (who, sight);
      }
    }
    return null;
  }

  /// The pointer's words.
  static String pointed((int, int) aim, int say) =>
      'Set ${Rules.tellVillager(aim.$1)} on ${Rules.tellSight(aim.$2)} to '
      '${Rules.tellSay(say)}.';
}

/// Why six is the best there is: the words behind the Why button.
String whyWords(Play play) {
  final level = play.level;
  final number = Levels.all.indexOf(level) + 1;
  return 'Three villagers, a black or a white hat on each by the toss of a '
      'coin, and everyone sees the other two hats and never their own. At a '
      'word they all speak at once, each either naming a colour for their own '
      'hat or holding their tongue, and the village wins if at least one '
      'names a colour and every colour named is right. They may agree '
      'anything beforehand.\n\n'
      'Guessing gets them nowhere on its own: one villager naming a colour '
      'and the others quiet wins four hattings of the eight, and so does any '
      'other agreement where the words never double up. The trick is to make '
      'the wrong words pile onto the same few hattings. Speak only when the '
      'two hats you can see match, and name the other colour: on the two '
      'hattings where all three hats are the same everyone speaks and '
      'everyone is wrong, and on the other six exactly one villager sees a '
      'matching pair and is right. Six of eight.\n\n'
      'Six cannot be beaten, and the reason is a count. Every word an '
      'agreement calls for is right on one of the two hattings that sight '
      'allows and wrong on the other, so the wrong words are as many as the '
      'words, and a hatting the village loses can swallow at most three of '
      'them. Todd Ebert asked the question in 1998, and the answer for '
      'larger rings is a covering code, which Lenstra and Seroussi wrote up '
      'in 2002.\n\n'
      'This is ask $number, ${level.name}. ${level.note}\n\n'
      'The counts in this note are the sweep\'s: every agreement the three '
      'can come to, all 531,441 of them, tried against all eight hattings '
      'before the sham was built.';
}
