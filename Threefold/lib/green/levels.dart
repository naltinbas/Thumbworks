import 'level.dart';

/// The five asks, first to last. Every count is the sweep's, and the
/// checker refuses the bake if any drifts.
class Levels {
  static const all = <Level>[
    Level(
      name: 'The Middle',
      kind: 'equal',
      ways: 1,
      aim: (4, 4, 4),
      note: 'One point of the 91 stands four rungs from every side, the '
          'middle of the green: 4 + 4 + 4 is the height of twelve, and its '
          'three triangles are a third of the green each, 96 of 288.',
    ),
    Level(
      name: 'The One Two Nine',
      kind: 'oneTwoNine',
      ways: 6,
      aim: (1, 2, 9),
      note: 'Six points of the 91 stand 1, 2 and 9 rungs from the sides, one '
          'for each order, and 1 + 2 + 9 is twelve as it must be: their '
          'triangles are 24, 48 and 216 of 288, twelfths of the green by the '
          'rungs.',
    ),
    Level(
      name: 'The Edge',
      kind: 'edge',
      ways: 3,
      aim: (0, 6, 6),
      note: 'Three points of the 91 stand on a side with the two other '
          'distances alike, the middle of each side, six rungs from each of '
          'the others: 0 + 6 + 6 is twelve, the triangle on the side stood '
          'on being flat and the other two half the green each.',
    ),
    Level(
      name: 'The Doubles',
      kind: 'doubles',
      ways: 6,
      aim: (2, 4, 6),
      note: 'Six points of the 91 have one distance twice another and the '
          'third the two added: 2, 4 and 6 in every order, since a + 2a + '
          '3a is twelve only at a of two. Their triangles are 48, 96 and 144 '
          'of 288.',
    ),
    Level(
      name: 'The Longer Walk',
      kind: 'longer',
      ways: 0,
      aim: null,
      note: 'Hopeless, and the tile says so. The three triangles a point makes '
          'with the sides fill the green exactly, each is half a side times a '
          'distance, and the sides are all alike, so the distances add to '
          'twice the area over the side, the height, wherever the point '
          'stands: twelve rungs on every one of the 91 points, never more.',
    ),
  ];

  static int get count => all.length;

  static Level at(int number) => all[number];
}
