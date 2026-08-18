import 'level.dart';

/// The five asks, first to last. Every count is the sweep's, and the checker
/// refuses the bake if one drifts.
class Levels {
  static const all = <Level>[
    Level(
      name: 'The Even Fence',
      climbCap: 4,
      dropCap: 4,
      aim: [4, 3, 2, 1, 7, 6, 5, 9, 8, 10],
      ways: 985032,
      fewest: 6,
      note: '985,032 of the 3,628,800 fences do it, better than one in four. '
          'Four and four is roomy. Every tag has to sit inside a box four '
          'wide and four deep, and that box holds sixteen tags, well past '
          'the ten palings there are to hang them on.',
    ),
    Level(
      name: 'The Matched Fence',
      climbCap: 10,
      dropCap: 10,
      matched: true,
      aim: [5, 4, 3, 2, 1, 7, 6, 8, 9, 10],
      ways: 970528,
      fewest: 5,
      note: '970,528 fences have the two runs at the same length, and that '
          'length is four or five, never anything else. Four at least, '
          'because three and three cannot be done. Five at most, because a '
          'climb and a drop can share one paling and no more, so six of each '
          'would want eleven palings and the fence has ten.',
    ),
    Level(
      name: 'The Short Climb',
      climbCap: 3,
      dropCap: 10,
      aim: [4, 3, 2, 1, 7, 6, 5, 10, 9, 8],
      ways: 586590,
      fewest: 7,
      note: '586,590 fences keep every climb under four, and every last one '
          'of them has a drop of four somewhere. That is forced rather than '
          'unlucky: with the climbs held to three, the front number on a tag '
          'can only be one, two or three, so ten palings and ten different '
          'tags need a back number of four or more on one of them.',
    ),
    Level(
      name: 'The Short Drop',
      climbCap: 4,
      dropCap: 3,
      aim: [3, 2, 1, 6, 5, 4, 8, 7, 10, 9],
      ways: 107604,
      fewest: 6,
      note: '107,604 fences do it, about one in thirty four. This pair of '
          'limits cannot be tightened. Take the climb down and it is three '
          'and three, which is the theorem. Take the drop down and it is a '
          'box of eight tags for ten palings. Turn it round and ask for a '
          'climb under four with a drop under five and the count is the same '
          '107,604.',
    ),
    Level(
      name: 'The Three and the Three',
      climbCap: 3,
      dropCap: 3,
      aim: [],
      ways: 0,
      fewest: null,
      note: 'Hopeless, and the card at the end of the ask says so. Hang a tag '
          'on every paling reading the longest climb ending there and the '
          'longest drop ending there. No two palings can carry the same tag, '
          'because of any two the taller one either stands to the right, '
          'which lengthens its climb, or to the left, which lengthens the '
          'other one\'s drop. Tags with both numbers under four come to nine, '
          'and there are ten palings. That is the Erdos and Szekeres '
          'theorem, and the sweep agrees on all 3,628,800 fences.',
    ),
  ];

  static int get count => all.length;

  static Level at(int number) => all[number];
}
