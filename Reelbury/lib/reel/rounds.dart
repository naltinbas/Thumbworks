import 'hall.dart';

/// One round of the dance: a hall, and the two sides' names.
class Round {
  const Round({
    required this.name,
    required this.callers,
    required this.dancers,
  });

  final String name;

  /// For each caller, the dancers in the order they would have them.
  final List<List<int>> callers;

  /// For each dancer, the callers in the order they would have them.
  final List<List<int>> dancers;

  Hall get hall => Hall(callers: callers, dancers: dancers);

  int get count => callers.length;

  /// The names, which are only ever the first however many of these. Two
  /// sides that start at opposite ends of the alphabet, so nobody ever has to
  /// work out which side a name is on.
  static const callerNames = <String>[
    'Ada',
    'Bram',
    'Cass',
    'Dai',
    'Elin',
    'Finn',
    'Gwen',
  ];

  static const dancerNames = <String>[
    'Rook',
    'Sedge',
    'Teal',
    'Vane',
    'Wren',
    'Yarrow',
    'Zeph',
  ];

  String callerName(int who) => callerNames[who];
  String dancerName(int who) => dancerNames[who];
}

/// The rounds, in the order they are met.
///
/// Every one of them has exactly one pairing that holds, and that is checked
/// rather than hoped: a test tries all of them, every way of pairing the two
/// sides up, and fails if a second one holds. Two answers and there is
/// nothing to work out, because a guess can be as right as a reason.
class Rounds {
  const Rounds._();

  static const all = <Round>[
    Round(
      name: 'Three couples',
      callers: [
        [0, 1, 2],
        [2, 0, 1],
        [0, 2, 1],
      ],
      dancers: [
        [1, 0, 2],
        [0, 2, 1],
        [2, 0, 1],
      ],
    ),
    Round(
      name: 'The first set',
      callers: [
        [3, 2, 1, 0],
        [3, 1, 2, 0],
        [1, 2, 3, 0],
        [1, 3, 2, 0],
      ],
      dancers: [
        [0, 1, 2, 3],
        [0, 1, 3, 2],
        [2, 0, 3, 1],
        [3, 2, 0, 1],
      ],
    ),
    Round(
      name: 'Cross hands',
      callers: [
        [0, 2, 3, 1],
        [3, 0, 2, 1],
        [2, 0, 3, 1],
        [2, 0, 1, 3],
      ],
      dancers: [
        [3, 0, 1, 2],
        [3, 2, 0, 1],
        [1, 0, 3, 2],
        [3, 0, 2, 1],
      ],
    ),
    Round(
      name: 'The long set',
      callers: [
        [4, 2, 1, 0, 3],
        [2, 3, 4, 0, 1],
        [1, 0, 2, 4, 3],
        [2, 1, 3, 4, 0],
        [2, 4, 0, 3, 1],
      ],
      dancers: [
        [1, 2, 4, 0, 3],
        [1, 2, 0, 3, 4],
        [0, 3, 1, 2, 4],
        [0, 4, 1, 3, 2],
        [2, 4, 0, 1, 3],
      ],
    ),
    Round(
      name: 'Down the middle',
      callers: [
        [3, 1, 2, 0, 4],
        [3, 2, 1, 0, 4],
        [4, 2, 1, 3, 0],
        [2, 1, 3, 4, 0],
        [4, 1, 3, 0, 2],
      ],
      dancers: [
        [2, 0, 4, 1, 3],
        [3, 0, 2, 1, 4],
        [1, 3, 4, 0, 2],
        [2, 4, 0, 3, 1],
        [3, 4, 1, 2, 0],
      ],
    ),
    Round(
      name: 'The whole floor',
      callers: [
        [4, 1, 0, 2, 3, 5],
        [5, 3, 4, 0, 2, 1],
        [0, 5, 3, 1, 2, 4],
        [5, 3, 4, 0, 2, 1],
        [1, 4, 0, 2, 3, 5],
        [5, 1, 2, 3, 4, 0],
      ],
      dancers: [
        [4, 1, 5, 3, 0, 2],
        [1, 0, 5, 3, 2, 4],
        [3, 1, 5, 0, 4, 2],
        [5, 4, 2, 1, 0, 3],
        [1, 5, 4, 2, 3, 0],
        [5, 3, 4, 2, 1, 0],
      ],
    ),
    Round(
      name: 'The last waltz',
      callers: [
        [3, 0, 6, 5, 2, 4, 1],
        [0, 4, 3, 1, 5, 2, 6],
        [6, 4, 2, 0, 5, 3, 1],
        [0, 4, 6, 1, 5, 3, 2],
        [0, 2, 4, 6, 3, 1, 5],
        [4, 3, 6, 0, 2, 5, 1],
        [3, 5, 0, 4, 1, 6, 2],
      ],
      dancers: [
        [4, 2, 6, 3, 0, 1, 5],
        [4, 0, 1, 6, 5, 3, 2],
        [2, 4, 0, 6, 1, 3, 5],
        [1, 5, 4, 2, 6, 0, 3],
        [2, 6, 1, 4, 5, 0, 3],
        [2, 0, 4, 1, 3, 6, 5],
        [3, 5, 1, 6, 4, 0, 2],
      ],
    ),
  ];

  static int get count => all.length;

  static Round at(int which) => all[which.clamp(0, all.length - 1)];
}
