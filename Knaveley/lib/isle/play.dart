import 'level.dart';
import 'levels.dart';
import 'rules.dart';

/// One go at an ask: who has been named what, the taps taken, and the
/// go before, so a naming can be taken back.
class Play {
  const Play._({
    required this.level,
    required this.naming,
    required this.moves,
    required this.seen,
    required this.before,
  });

  Play.of(this.level)
      : naming = const [],
        moves = 0,
        seen = const {},
        before = null;

  /// A go standing at a naming, no taps counted: what the mark draws.
  Play.standing(this.level, this.naming)
      : moves = 0,
        seen = const {},
        before = null;

  final Level level;

  /// Who is a knight and who a knave. Empty means everybody a knight,
  /// which is how an ask opens.
  final List<bool> naming;

  /// The taps taken.
  final int moves;

  /// The namings tried on a hopeless ask.
  final Set<String> seen;

  final Play? before;

  /// The taps a hopeless ask runs to before the sham admits it.
  static const gaveUpAt = 14;

  /// The namings a hopeless ask lets the player try before the sham
  /// admits it.
  static const enough = 4;

  /// The naming as a list, everybody a knight when nothing has been
  /// tapped.
  List<bool> get kinds => naming.isEmpty
      ? [for (var i = 0; i < level.villagers; i++) Rules.knight]
      : naming;

  /// The villagers whose kind and telling disagree.
  List<int> get caught => Rules.caught(level.tellings, kinds);

  /// Whether villager [who] is telling the truth as things stand.
  bool tellsTrue(int who) =>
      Rules.holds(level.tellings[who], who, kinds);

  /// Turns villager [who] from knight to knave or back.
  Play turn(int who) {
    if (isOver || who < 0 || who >= level.villagers) return this;
    final next = List.of(kinds)..[who] = !kinds[who];
    final nowSeen = !level.winnable
        ? {...seen, next.map((kind) => kind ? 'K' : 'n').join()}
        : seen;
    return Play._(
      level: level,
      naming: next,
      moves: moves + 1,
      seen: nowSeen,
      before: this,
    );
  }

  Play get back => before ?? this;

  bool get isDone => level.winnable && level.meets(kinds);

  /// A hopeless ask, admitted: [enough] namings tried, or [gaveUpAt]
  /// taps gone.
  bool get gaveUp =>
      !level.winnable && (seen.length >= enough || moves >= gaveUpAt);

  bool get isOver => isDone || gaveUp;

  /// The villager the pointer names, the first whose kind differs from
  /// the naming the sweep found; null when there is nothing to point
  /// at.
  int? get next {
    final aim = level.aim;
    if (aim == null || isOver) return null;
    for (var who = 0; who < level.villagers; who++) {
      if (kinds[who] != aim[who]) return who;
    }
    return null;
  }

  /// The pointer's words.
  String pointed(int who) => kinds[who]
      ? 'Call ${Rules.tellName(who)} a knave.'
      : 'Call ${Rules.tellName(who)} a knight.';
}

/// Why one telling cannot be made at all: the words behind the Why
/// button.
String whyWords(Play play) {
  final level = play.level;
  final number = Levels.all.indexOf(level) + 1;
  return 'On this island a knight says nothing but the truth and a knave '
      'nothing but falsehood. Each villager makes one telling, and a naming '
      'holds when every villager\'s kind matches the truth of what that '
      'villager says: a knight\'s telling true, a knave\'s false.\n\n'
      'That is all the arithmetic there is. With so many villagers there are '
      'two to that many namings, and the sham tries every one of them. Some '
      'sets of tellings are held by exactly one naming, some by several, and '
      'some by none at all.\n\n'
      'The one that is held by none is worth the trouble. A villager who '
      'says "I am a knave" cannot be a knight, since the telling would be '
      'false, and cannot be a knave either, since it would be true. Nobody '
      'on the island can say it, whatever anybody else says, so every naming '
      'is caught out at that villager. Puzzles of this kind are Raymond '
      'Smullyan\'s, from What Is the Name of This Book? in 1978.\n\n'
      'This is ask $number, ${level.name}. ${level.note}\n\n'
      'The counts in this note are the sweep\'s: every naming of every ask, '
      'tried in full before the sham was built.';
}
