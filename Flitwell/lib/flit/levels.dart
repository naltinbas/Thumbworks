import 'level.dart';

/// The five asks, first to last. Every count is the sweep's, and the
/// checker refuses the bake if one drifts.
class Levels {
  /// The street the second, fourth and fifth asks are all set in. Three
  /// asks on one lane is the point of it: seven lanes no group can
  /// better all at once, one of those seven that no group can better at
  /// all, and nothing at all that beats that one.
  static const shared = 'BCAD DACB BADC ACBD';

  static const all = <Level>[
    Level(
      name: 'The Willing Lane',
      street: 'BCDA ACDB ABDC ABCD',
      kind: 'better',
      ways: 9,
      fewest: 2,
      note: '9 of the 24 lanes land it. Every tenant on this street puts '
          'their own cottage last, so a lane suits everybody exactly when '
          'it leaves nobody at home, and there are 9 ways to move all four '
          'of them. Wanting to move is not the same as being able to agree '
          'on where, which is the next ask.',
    ),
    Level(
      name: 'The Lane They Cannot Beat',
      street: shared,
      kind: 'settled',
      ways: 7,
      fewest: 2,
      note: '7 of the 24 lanes land it, and 7 is as many as a street of four '
          'ever reaches: of the 331,776 streets the sweep walks, 72 have a '
          'lane count that high. A group only counts as beating a lane if '
          'every one of its members gains, and a group can only shuffle the '
          'cottages its own members own.',
    ),
    Level(
      name: 'The Three That Suit',
      street: 'BCAD ACDB BDCA ABDC',
      kind: 'better',
      ways: 3,
      fewest: 3,
      note: '3 of the 24 lanes land it, and the nearest is 3 swaps off, '
          'which is as far as four cottages go: any lane can be reached in '
          'three swaps and some need all three. Two tenants here would '
          'sooner stay than take most of what is on offer, so the lanes '
          'that suit everybody are thin on the ground.',
    ),
    Level(
      name: 'The Firm Lane',
      street: shared,
      kind: 'firm',
      ways: 1,
      fewest: 2,
      note: '1 of the 24, and one is the answer on every street the sweep '
          'walks. It is one of the seven from the second ask, and the other '
          'six all have a group that could better one of its own without '
          'setting another back. Look at who ends up where: A, B and D each '
          'get the cottage they want most, and C is left in the one it '
          'wants least. That is what the lane protects, since C owns its '
          'cottage and nobody can take it, and it is why nothing can be '
          'improved.',
    ),
    Level(
      name: 'The Better Lane',
      street: shared,
      kind: 'beat',
      ways: 0,
      fewest: null,
      note: 'Hopeless, and the card at the end of the ask says so. In the '
          'firm lane A, B and D are each in the cottage they want most, so '
          'no lane anywhere can leave any of the three better off, let '
          'alone all four. The trading rings say the same thing without '
          'looking at a single lane: the tenants in the first ring get '
          'their first choice, so no lane ever beats the one the rings '
          'give.',
    ),
  ];

  static int get count => all.length;

  static Level at(int number) => all[number];
}
