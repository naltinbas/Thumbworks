import 'level.dart';
import 'levels.dart';
import 'rules.dart';

/// One go at an ask: the stones stood on so far, the hops taken, the
/// standings that showed the long shallows whole, and the go before, so
/// a hop can be taken back.
class Play {
  const Play._({
    required this.level,
    required this.stones,
    required this.moves,
    required this.seen,
    required this.before,
  });

  Play.of(this.level)
      : stones = const [Rules.start],
        moves = 0,
        seen = const {},
        before = null;

  /// A go standing part way across, no hops counted: what the mark
  /// draws.
  Play.standing(this.level, this.stones)
      : moves = 0,
        seen = const {},
        before = null;

  final Level level;

  /// The crossing so far, first stone to last.
  final List<int> stones;

  /// The hops taken.
  final int moves;

  /// The stones stood on whose rope covered the whole of the long
  /// shallows.
  final Set<int> seen;

  final Play? before;

  /// The hops a hopeless ask runs to before the sham admits it.
  static const gaveUpAt = 16;

  /// The standings that show the long shallows whole before the sham
  /// admits it.
  static const enough = 3;

  /// The stone under your feet.
  int get at => stones.last;

  /// Where the rope from it ends.
  int get rope => Rules.ropeEnd(at);

  /// The dry stones the rope covers.
  List<int> get inReach => Rules.inReach(at);

  /// Nothing dry left in reach: the ford ends here.
  bool get stuck => inReach.isEmpty;

  /// Why a tap on [stone] is no hop, or null when it is a fair one.
  String? refusal(int stone) {
    if (!Rules.onFord(stone)) return 'that is off the ford';
    if (stone == at) return 'you are standing on stone $stone';
    if (stone < at) return 'the crossing goes on, not back';
    if (stone > rope) {
      return 'the rope from stone $at reaches only as far as $rope';
    }
    if (!Rules.dry(stone)) return '${Rules.tellMoss(stone)}, and mossy';
    return null;
  }

  /// Hops to [stone] if the rope reaches it and it is dry.
  Play hop(int stone) {
    if (isOver || !Rules.canHop(at, stone)) return this;
    final nowSeen =
        Rules.coversShallows(stone) ? {...seen, stone} : seen;
    return Play._(
      level: level,
      stones: [...stones, stone],
      moves: moves + 1,
      seen: nowSeen,
      before: this,
    );
  }

  Play get back => before ?? this;

  bool get isDone => level.winnable && level.meets(at);

  /// A hopeless ask, admitted: [enough] standings that showed the long
  /// shallows whole, or [gaveUpAt] hops gone.
  bool get gaveUp =>
      !level.winnable && (seen.length >= enough || moves >= gaveUpAt);

  bool get isOver => isDone || gaveUp;

  /// The stone the pointer names, the first hop on a shortest crossing
  /// to one that lands the ask; null when there is nothing to point at.
  int? get next => isOver ? null : Rules.towards(at, level.meets);

  /// The pointer's words.
  static String pointed(int stone) => 'Hop to stone $stone.';
}

/// Why the ford can never strand you: the words behind the Why button.
String whyWords(Play play) {
  final level = play.level;
  final number = Levels.all.indexOf(level) + 1;
  return 'The stones of the ford are numbered from the near bank, and the '
      'dry ones are the primes. Standing on stone n, the rope reaches exactly '
      'as far as 2n, and a hop may go to any dry stone past n that the rope '
      'covers. Bertrand\'s postulate says there is always one: for every n '
      'above 1 there is a prime p with n < p < 2n. Joseph Bertrand put it in '
      '1845 after checking the numbers up to three million; Pafnuty '
      'Chebyshev proved it in 1852, and Paul Erdos gave the short proof in '
      '1932, in his first published paper.\n\n'
      'What the postulate does not say is where the dry stone will be, and '
      'that is the game. The small cases are settled with a chain of stones '
      'each less than twice the one before, ${Rules.chain.join(', ')} here, '
      'and the same chain is what the crossing does when it always takes the '
      'farthest stone in reach.\n\n'
      'The sham sieves the ford twice, once by Eratosthenes and once by '
      'trial division, walks every stone of it for the fewest hops, and '
      'checks the promise on every number it can reach.\n\n'
      'This is ask $number, ${level.name}. ${level.note}\n\n'
      'The tile\'s counts are the sweep\'s: every stone of the ford, taken '
      'in turn.';
}
