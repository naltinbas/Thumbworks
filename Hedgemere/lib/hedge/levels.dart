import 'level.dart';

/// The five asks, first to last. Each ways count is the sweep's, and
/// the checker refuses the bake if one drifts.
class Levels {
  static const all = <Level>[
    Level(
      name: 'The Middle Post',
      middles: 1,
      rounds: 2,
      ways: 378,
      aim: [2, 3, 3, 4, 5],
      note: '378 hangings of the 720 peel to one post in two rounds, more '
          'than any other ask here, because a hedge of seven posts is most '
          'often four steps end to end. A longest walk of four steps has one '
          'post at its halfway mark, and that post is the middle.',
    ),
    Level(
      name: 'The Long Hedge',
      middles: 1,
      rounds: 3,
      ways: 32,
      aim: [2, 3, 4, 5, 6],
      note: '32 hangings of the 720 land it, and every one of them is the '
          'same shape, all seven posts in a single line, though the middle '
          'post is not the same one in each. Six steps end to '
          'end is the longest walk seven posts can make, the fourth post '
          'along stands in the middle, and it takes three rounds to strip '
          'down to it.',
    ),
    Level(
      name: 'The Even Hedge',
      middles: 2,
      rounds: 1,
      ways: 82,
      aim: [2, 2, 2, 2, 6],
      note: '82 hangings of the 720 leave two posts standing after a single '
          'round. Two middle posts means the longest walk is an odd number '
          'of steps, and one round means three: two posts in the middle with '
          'everything else hanging straight off one or the other.',
    ),
    Level(
      name: 'The Round Bush',
      middles: 1,
      rounds: 1,
      ways: 2,
      aim: [2, 2, 2, 2, 2],
      note: 'Two hangings of the 720, and they are the only hedges here in '
          'which every post but one is a leaf: all six hanging off post 1, '
          'or all six hanging off post 2. Two steps end to end, one round, '
          'and the post in the middle is the one holding the rest.',
    ),
    Level(
      name: 'The Three Middles',
      middles: 3,
      rounds: 1,
      ways: 0,
      aim: null,
      note: 'Hopeless, and the card at the end of the ask says so. Walk the '
          'hedge from one end of its longest path to the other. The middle '
          'sits at the halfway mark of that walk, and a walk of an even '
          'number of steps has one post halfway while a walk of an odd '
          'number has two. There is no third place on a line to stand '
          'halfway, so no hedge has three middle posts, whatever the '
          'rounds. All 720 hangings the dials reach were peeled before the '
          'sham was built, and every one of them left one post or two.',
    ),
  ];

  static int get count => all.length;

  static Level at(int number) => all[number];
}
