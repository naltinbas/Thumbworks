import 'level.dart';

/// The five asks, first to last. Every count is the sweep's, and the
/// checker refuses the bake if any drifts.
class Levels {
  static const all = <Level>[
    Level(
      name: 'The Ten',
      kind: 'ten',
      ways: 1024,
      note: 'Of the 184,756 families of ten trios, 1,024 have every two '
          'sharing a friend, and they are exactly the pickings of one trio '
          'from each of the ten missing pairs, two ways ten times over; the '
          '59,049 sharing families of every size are three to the ten, each '
          'pair left alone or entered one way or the other.',
    ),
    Level(
      name: 'The Star',
      kind: 'star',
      ways: 6,
      note: 'Ten trios all holding one friend share throughout, and there '
          'are six such stars, one a friend; the other 1,018 sharing tens '
          'have no friend in all of them, and 60 of the 1,024 have a friend '
          'in nine.',
    ),
    Level(
      name: 'The Even Hand',
      kind: 'even',
      ways: 12,
      note: 'Only 12 of the 1,024 sharing tens deal every friend into five '
          'trios exactly: ABC, ABD, ACE, ADF, AEF, BCF, BDE, BEF, CDE and '
          'CDF is one, and no friend can be dealt fewer than five in a '
          'sharing ten, since ten trios hold thirty places and no friend '
          'is in more than ten.',
    ),
    Level(
      name: 'The Fifteen',
      kind: 'fifteen',
      ways: 8064,
      note: 'Fifteen trios must take both trios of five missing pairs at '
          'least, so five pairs apart is the fewest, and 8,064 families of '
          'fifteen have five exactly, both of five pairs and one of each of '
          'the other five; the whole twenty have ten pairs apart.',
    ),
    Level(
      name: 'The Eleven',
      kind: 'eleven',
      ways: 0,
      note: 'Hopeless, and the tile says so. Two trios of six friends miss '
          'each other only when one is the other three, so the twenty trios '
          'fall into ten missing pairs, ABC with DEF, ABD with CEF and on, '
          'and a family in which every two share a friend takes one trio of '
          'each pair at most: ten. Erdos, Ko and Rado proved it in general '
          'in 1961, for k-sets of n things with n at least 2k, the star of '
          'one thing being as large as any. The sweep of all 1,048,576 '
          'families finds 59,049 sharing throughout, 1,024 of ten trios and '
          'none of eleven.',
    ),
  ];

  static int get count => all.length;

  static Level at(int number) => all[number];
}
