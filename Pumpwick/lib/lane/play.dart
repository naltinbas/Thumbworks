import 'level.dart';
import 'levels.dart';
import 'rules.dart';

/// One go at an ask: where the pump stands, the steps it has taken, and
/// the go before, so a step can be taken back.
class Play {
  const Play._({
    required this.level,
    required this.spot,
    required this.moves,
    required this.seen,
    required this.before,
  });

  Play.of(this.level)
      : spot = Rules.start,
        moves = 0,
        seen = const {},
        before = null;

  /// A go standing at a spot, no steps counted: what the mark draws.
  Play.standing(this.level, this.spot)
      : moves = 0,
        seen = const {},
        before = null;

  final Level level;

  /// Where the pump stands.
  final int spot;

  /// The steps taken.
  final int moves;

  /// The spots stood on that gave the least walking there is.
  final Set<int> seen;

  final Play? before;

  /// The steps a hopeless ask runs to before the sham admits it.
  static const gaveUpAt = 20;

  /// The best spots a hopeless ask lets the player find before the sham
  /// admits it. One is enough: standing on the least is the whole of
  /// the argument.
  static const enough = 1;

  List<int> get houses => level.houses;

  /// What the walking comes to as the pump stands.
  int get walk => Rules.walk(houses, spot);

  /// The least it can come to.
  int get least => Rules.leastWalk(houses);

  /// How the total would change on stepping one spot further along.
  int get stepChange => Rules.stepChange(houses, spot);

  /// Steps the pump one spot, up the lane or down it.
  Play step(int by) {
    final to = spot + by;
    if (isOver || by == 0 || by.abs() != 1 || !Rules.onLane(to)) return this;
    final nowSeen = Rules.walk(houses, to) == Rules.leastWalk(houses)
        ? {...seen, to}
        : seen;
    return Play._(
      level: level,
      spot: to,
      moves: moves + 1,
      seen: nowSeen,
      before: this,
    );
  }

  /// Steps the pump one spot towards [where].
  Play towards(int where) {
    if (where == spot) return this;
    return step(where > spot ? 1 : -1);
  }

  Play get back => before ?? this;

  bool get isDone => level.winnable && level.meets(spot);

  /// A hopeless ask, admitted: [enough] of the best spots stood on, or
  /// [gaveUpAt] steps taken.
  bool get gaveUp =>
      !level.winnable && (seen.length >= enough || moves >= gaveUpAt);

  bool get isOver => isDone || gaveUp;

  /// Which way the pointer sends the pump, or null.
  int? get next {
    final aim = level.aim;
    if (aim == null || isOver || aim == spot) return null;
    return aim > spot ? 1 : -1;
  }

  /// The pointer's words.
  static String pointed(int by) =>
      by > 0 ? 'Roll the pump one spot up the lane.' : 'Roll it one spot back.';
}

/// Why the middle house wins: the words behind the Why button.
String whyWords(Play play) {
  final level = play.level;
  final number = Levels.all.indexOf(level) + 1;
  return 'Houses along a lane and a pump to stand somewhere on it. Everybody '
      'walks to the pump, so what counts is the distances added up.\n\n'
      'Step the pump one spot along and watch the total. Every house behind '
      'it is a spot further off, and every house ahead is a spot nearer, so '
      'the total changes by the houses behind less the houses ahead. While '
      'more houses lie ahead the total falls, and once more lie behind it '
      'rises. The least is where the two counts even out, and that is the '
      'middle house: with an odd count of houses the middle one exactly, and '
      'with an even count every spot from the lower middle house to the '
      'upper one, since between them the two counts are equal and the total '
      'does not move at all.\n\n'
      'The average is a different animal. It is pulled by how far a house '
      'is, not just by which side it lies on, so one cottage away up the '
      'lane drags the average after it while the middle house stays where it '
      'was. The pump wants the middle, and it is the least walking that says '
      'so.\n\n'
      'This is ask $number, ${level.name}. ${level.note}\n\n'
      'The counts in this note are the sweep\'s: every row of houses on the '
      'lane, walked in full before the sham was built.';
}
