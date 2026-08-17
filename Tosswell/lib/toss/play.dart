import 'level.dart';
import 'levels.dart';
import 'rules.dart';

/// One go at an ask: which standings are marked, the marks made, and
/// the go before, so a mark can be taken back.
class Play {
  const Play._({
    required this.level,
    required this.stop,
    required this.moves,
    required this.seen,
    required this.before,
  });

  Play.of(this.level)
      : stop = const {},
        moves = 0,
        seen = const {},
        before = null;

  /// A go standing at a rule, no marks counted: what the mark draws.
  Play.standing(this.level, this.stop)
      : moves = 0,
        seen = const {},
        before = null;

  final Level level;

  /// The standings the rule walks away from.
  final Set<String> stop;

  /// The marks made.
  final int moves;

  /// The rules tried on a hopeless ask.
  final Set<String> seen;

  final Play? before;

  /// The marks a hopeless ask runs to before the sham admits it.
  static const gaveUpAt = 16;

  /// The rules a hopeless ask lets the player try before the sham
  /// admits it.
  static const enough = 4;

  /// Where each of the 32 runs walks away.
  List<int> get ends => Rules.ends(stop);

  /// How many runs walk away ahead.
  int get ahead => Rules.aheadIn(ends);

  int get worst => Rules.worstIn(ends);

  int get best => Rules.bestIn(ends);

  /// The purse added over all 32 runs, which is always nothing.
  int get added => Rules.added(ends);

  /// How many runs walk away at each standing.
  Map<String, int> get ending => Rules.ending(stop);

  bool marked((int, int) at) => stop.contains(Rules.mark(at));

  bool alive((int, int) at) => Rules.alive(stop, at);

  Play _to(Set<String> to) {
    final at = (to.toList()..sort()).join(' ');
    return Play._(
      level: level,
      stop: to,
      moves: moves + 1,
      seen: !level.winnable ? {...seen, at} : seen,
      before: this,
    );
  }

  /// Marks a standing to walk away from, or takes the mark off again.
  /// A standing the coin can no longer reach is not worth marking, so
  /// the tap is refused.
  Play tap((int, int) at) {
    if (isOver || !Rules.reachable(at) || at.$1 >= Rules.tosses) return this;
    final key = Rules.mark(at);
    if (stop.contains(key)) {
      return _to({...stop}..remove(key));
    }
    if (!alive(at)) return this;
    return _to({...stop, key});
  }

  Play get back => before ?? this;

  bool get isDone => level.winnable && level.meets(stop);

  /// A hopeless ask, admitted: [enough] rules tried, or [gaveUpAt]
  /// marks made.
  bool get gaveUp =>
      !level.winnable && (seen.length >= enough || moves >= gaveUpAt);

  bool get isOver => isDone || gaveUp;

  /// The marks left to the ask, and the standing to mark first. Walked
  /// outward from the rule as it stands.
  (int, (int, int))? get toGo {
    if (level.meets(stop)) return (0, (0, 0));
    final standings = Rules.standings();
    final seenRules = <String>{(stop.toList()..sort()).join(' ')};
    var edge = <Set<String>>[stop];
    final first = <String, (int, int)>{};
    for (var away = 1; away <= standings.length; away++) {
      final next = <Set<String>>[];
      for (final rule in edge) {
        final from = (rule.toList()..sort()).join(' ');
        for (final at in standings) {
          final key = Rules.mark(at);
          if (rule.contains(key) || !Rules.alive(rule, at)) continue;
          final to = {...rule, key};
          final id = (to.toList()..sort()).join(' ');
          if (!seenRules.add(id)) continue;
          first[id] = identical(rule, stop) ? at : first[from]!;
          if (level.meets(to)) return (away, first[id]!);
          next.add(to);
        }
      }
      if (next.isEmpty) return null;
      edge = next;
    }
    return null;
  }

  /// What the pointer says, or null when there is nothing to point at.
  (int, int)? get next {
    if (isOver) return null;
    final go = toGo;
    return go == null || go.$1 == 0 ? null : go.$2;
  }

  /// The pointer's words.
  static String pointed((int, int) at) =>
      'Mark ${Rules.tellStanding(at)}.';
}

/// Why the purse averages nothing: the words behind the Why button.
String whyWords(Play play) {
  final level = play.level;
  final number = Levels.all.indexOf(level) + 1;
  return 'Five tosses of a fair coin. Heads and the purse goes up a shilling, '
      'tails and it goes down one. Before each toss you may walk away with '
      'what you have, and the rule for walking away is yours to write: mark '
      'the standings you would leave at.\n\n'
      'Whatever you mark, the 32 runs of the coin average nothing. Work back '
      'from the last row. At any standing the two tosses that leave it are '
      'worth one more and one less and they are equally likely, so the '
      'standing is worth exactly what it holds. Walking away there is worth '
      'what it holds as well. So marking a standing changes nothing about '
      'what it is worth, and the same goes for the row before it, and the row '
      'before that, back to the start where the purse holds nothing.\n\n'
      'This is Doob\'s optional stopping theorem, for a rule that has to stop '
      'by the fifth toss. A fair game stays fair however you choose to leave '
      'it. What a rule can change is the shape of the thing: you can be ahead '
      'on 22 runs of the 32, which is the most there is, but then the runs '
      'that go against you go a long way against you, and it comes out level '
      'in the end.\n\n'
      'The sham works every rule twice: it walks all 32 runs of the coin and '
      'adds up what they walk away with, and it works the standings backward '
      'from the last row, averaging the two tosses out of each one, which '
      'walks no runs at all.\n\n'
      'This is ask $number, ${level.name}. ${level.note}\n\n'
      'The counts in this note are the sweep\'s: every rule for walking away '
      'walked in full before the sham was built.';
}
