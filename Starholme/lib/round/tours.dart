import 'tour.dart';

/// The five tours that ship.
///
/// Every number here is checked before the bake: the census of
/// every round at every length, the two-per-post law on the
/// nines, and tool/check_rounds.dart refuses the lot if
/// anything disagrees.
class Tours {
  static const all = [
    Tour(
      name: 'The Pentagon',
      posts: 5,
      ways: 12,
      note: 'Twelve pentagons is no accident: the star wears '
          'five-rounds everywhere, and five is its shortest '
          'round, the girth of the graph.',
    ),
    Tour(
      name: 'The Hexagon',
      posts: 6,
      ways: 10,
      note: 'Ten hexagons stand beside the twelve pentagons, '
          'and nothing stands between them: the star holds no '
          'seven-round at all.',
    ),
    Tour(
      name: 'The Eight Round',
      posts: 8,
      ways: 15,
      note: 'Fifteen eight-rounds, one for each lane: every '
          'eight-round leaves out two posts that share a '
          'lane.',
    ),
    Tour(
      name: 'The Nine Round',
      posts: 9,
      ways: 20,
      note: 'Every nine-round leaves exactly one post out, and '
          'every post can be the one: two tours apiece, ten '
          'posts, twenty rounds. Drop any post and the star '
          'still tours.',
    ),
    Tour(
      name: 'The Full Round',
      posts: 10,
      ways: 0,
      note: 'The nearest misses are the twenty nines, two for '
          'every post left out; the tenth post never joins. '
          'Petersen\'s star is the smallest such graph there '
          'is.',
    ),
  ];

  static int get count => all.length;

  static Tour at(int number) => all[number];
}
