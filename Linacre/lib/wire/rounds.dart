import 'game.dart';
import 'net.dart';

/// One round: a net, which part the player takes, and what winning costs.
class Round {
  Round({
    required this.name,
    required this.net,
    required this.part,
    required this.fewest,
  });

  final String name;
  final Net net;

  /// The part the player takes. The player always has first go.
  final Part part;

  /// The fewest of the player's own moves that force the win, or null on the
  /// round that cannot be won at all. Written down here as well as worked
  /// out, so a test can hold the two against each other.
  final int? fewest;

  bool get hopeless => fewest == null;
}

/// The rounds that ship.
///
/// The Toll Bridge appears twice, once from each chair, because whoever moves
/// first on that net wins it: the bridge wire is worth exactly the first
/// move. The Doubled Line appears twice the same way, and one of those two is
/// the round that cannot be won, labelled as such: two webs of wire each join
/// the stations, a cut wounds one web at most, and the linesman mends it
/// through the other. It ships to be felt, the way Warrenshaw ships a map
/// nobody can win.
class Rounds {
  const Rounds._();

  static final List<Round> all = [
    Round(name: 'The Loop Road', net: _thin(), part: Part.cutter, fewest: 2),
    Round(name: 'The Ladder', net: _ladder(2), part: Part.cutter, fewest: 3),
    Round(name: 'The Toll Bridge', net: _bridge(), part: Part.cutter, fewest: 3),
    Round(
      name: 'The Bridge Held',
      net: _bridge(),
      part: Part.linesman,
      fewest: 3,
    ),
    Round(name: 'The Long Line', net: _ladder(3), part: Part.cutter, fewest: 3),
    Round(
      name: 'The Doubled Line',
      net: _doubled(),
      part: Part.linesman,
      fewest: 2,
    ),
    Round(
      name: 'Past Cutting',
      net: _doubled(),
      part: Part.cutter,
      fewest: null,
    ),
  ];

  static int get count => all.length;

  static Round at(int number) => all[number.clamp(0, all.length - 1)];

  /// One search per round, kept between screens so what it settles is not
  /// thrown away and settled again.
  static final _games = <int, Game>{};

  static Game gameFor(int number) =>
      _games.putIfAbsent(number, () => Game(at(number).net));

  /// Empties what the searches have kept. For the tests.
  static void forget() => _games.clear();

  /// A single run of line with two loops on it. Thin everywhere, and the
  /// second loop is the one to open first.
  static Net _thin() => Net(
        name: 'The Loop Road',
        posts: const [
          Post('Aldergate', 0.08, 0.50),
          Post('First Post', 0.30, 0.28),
          Post('Middle Post', 0.50, 0.62),
          Post('Third Post', 0.70, 0.32),
          Post('Zeal End', 0.92, 0.50),
        ],
        wires: const [
          Wire(0, 1),
          Wire(1, 2),
          Wire(2, 3),
          Wire(3, 4),
          Wire(0, 2),
          Wire(2, 4),
        ],
        stationA: 0,
        stationB: 4,
      );

  /// Two runs of wire with rungs between them.
  static Net _ladder(int bays) {
    final posts = <Post>[
      const Post('Aldergate', 0.07, 0.50),
      for (var bay = 0; bay < bays; bay++) ...[
        Post('Top ${bay + 1}', 0.24 + bay * (0.52 / (bays - 1)), 0.26),
        Post('Low ${bay + 1}', 0.24 + bay * (0.52 / (bays - 1)), 0.74),
      ],
      const Post('Zeal End', 0.93, 0.50),
    ];
    int top(int bay) => 1 + bay * 2;
    int low(int bay) => 2 + bay * 2;
    final z = posts.length - 1;
    return Net(
      name: 'The Ladder',
      posts: posts,
      wires: [
        Wire(0, top(0)),
        Wire(0, low(0)),
        for (var bay = 0; bay < bays; bay++) Wire(top(bay), low(bay)),
        for (var bay = 0; bay + 1 < bays; bay++) ...[
          Wire(top(bay), top(bay + 1)),
          Wire(low(bay), low(bay + 1)),
        ],
        Wire(top(bays - 1), z),
        Wire(low(bays - 1), z),
      ],
      stationA: 0,
      stationB: z,
    );
  }

  /// A diamond with a bridge wire across the middle. Whoever has first go
  /// wins this net, and the bridge is why.
  static Net _bridge() => Net(
        name: 'The Toll Bridge',
        posts: const [
          Post('Aldergate', 0.10, 0.50),
          Post('North Post', 0.50, 0.20),
          Post('South Post', 0.50, 0.80),
          Post('Zeal End', 0.90, 0.50),
        ],
        wires: const [
          Wire(0, 1),
          Wire(0, 2),
          Wire(1, 3),
          Wire(2, 3),
          Wire(1, 2),
        ],
        stationA: 0,
        stationB: 3,
      );

  /// The diamond with every wire twinned. Two whole webs each join the
  /// stations, which settles the game before anybody moves.
  static Net _doubled() => Net(
        name: 'The Doubled Line',
        posts: const [
          Post('Aldergate', 0.10, 0.50),
          Post('North Post', 0.50, 0.20),
          Post('South Post', 0.50, 0.80),
          Post('Zeal End', 0.90, 0.50),
        ],
        wires: const [
          Wire(0, 1),
          Wire(0, 1),
          Wire(0, 2),
          Wire(0, 2),
          Wire(1, 3),
          Wire(1, 3),
          Wire(2, 3),
          Wire(2, 3),
        ],
        stationA: 0,
        stationB: 3,
      );
}
