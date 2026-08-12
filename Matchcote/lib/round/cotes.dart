import 'cote.dart';

/// The five cotes that ship.
///
/// Every number here is checked before the bake: the cover, the
/// sweep and the odd-crowd arithmetic, and tool/check_cotes.dart
/// refuses the lot if anything disagrees.
class Cotes {
  static const all = [
    Cote(
      name: 'The Four',
      players: 4,
      ways: 6,
      note: 'Four players fix in three rounds, and the six '
          'fixtures are one schedule worn six ways: the three '
          'rounds of it in any order.',
    ),
    Cote(
      name: 'The Fixed Opener',
      players: 6,
      given: [
        [(0, 1), (2, 3), (4, 5)],
      ],
      ways: 48,
      note: 'One round down leaves 48 roads to a full fixture: '
          'the opener costs nothing, since every fixture can be '
          'told starting anywhere.',
    ),
    Cote(
      name: 'The Two Given',
      players: 6,
      given: [
        [(0, 1), (2, 3), (4, 5)],
        [(0, 2), (1, 4), (3, 5)],
      ],
      ways: 6,
      note: 'Two rounds down and the room shrinks to six: the '
          'fixture is nearly told, and the last three rounds '
          'mostly tell themselves.',
    ),
    Cote(
      name: 'The Six',
      players: 6,
      ways: 720,
      note: 'Six players fix 720 ways counting the order of '
          'rounds: six bare schedules, each worn the 120 ways '
          'its five rounds arrange.',
    ),
    Cote(
      name: 'The Fifth Player',
      players: 5,
      ways: 0,
      note: 'A round pairs everyone at once, and five is odd: '
          'someone sits, every round, however the pairs fall. '
          'The sweep looked for a single full round among five '
          'players and found none to build on.',
    ),
  ];

  static int get count => all.length;

  static Cote at(int number) => all[number];
}
