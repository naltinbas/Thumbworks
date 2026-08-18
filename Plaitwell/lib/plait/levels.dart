import 'level.dart';

/// The five asks, first to last. Every count is the sweep's, and the checker
/// refuses the bake if one drifts.
class Levels {
  /// The trefoil on two ropes, which the mark draws.
  static const short = Level(
      name: 'The Short Plait',
      strands: 2,
      word: [1, 1, 1],
      knot: 'the trefoil',
      ways: 6,
      legal: 9,
      fewest: 3,
      note: '6 of the 27 paintings keep the rule and use all three colours, '
          'and 3 more keep the rule by painting the whole rope one colour. '
          'Those three exist on every plait ever drawn, which is why they do '
          'not count. This is the trefoil, the first knot there is.',
  );

  static const all = <Level>[
    short,
    Level(
      name: 'The Long Plait',
      strands: 3,
      word: [1, 2, 1, 2],
      knot: 'the trefoil again',
      ways: 6,
      legal: 9,
      fewest: 3,
      note: 'The same knot as the short plait, plaited another way: four '
          'crossings on three ropes rather than three on two. 6 paintings of '
          '81 land it, the same 6 as before. The count does not follow the '
          'drawing, it follows the knot, and the checker walks the three '
          'moves that turn one of these plaits into the other.',
    ),
    Level(
      name: 'The Granny',
      strands: 3,
      word: [1, 1, 1, 2, 2, 2],
      knot: 'two trefoils tied in a row',
      ways: 24,
      legal: 27,
      fewest: 3,
      note: '24 of the 729 paintings land it. Two trefoils one after the '
          'other, and the counts multiply the way you would hope: 9 legal '
          'paintings each, and joining them end to end gives 9 times 9 '
          'divided by 3, which is 27, of which 24 use all three colours.',
    ),
    Level(
      name: 'The Torus Plait',
      strands: 3,
      word: [1, 2, 1, 2, 1, 2, 1, 2],
      knot: 'the eight-crossing torus knot',
      ways: 6,
      legal: 9,
      fewest: 6,
      note: '6 of 6,561, which is the thinnest hunting on the list. This is '
          'not the trefoil, but it has the trefoil\'s 9 legal paintings all '
          'the same. So a count that matches proves nothing about two knots '
          'being the same. A count that differs proves they are not, and '
          'that is the whole use of it.',
    ),
    Level(
      name: 'The Figure Eight',
      strands: 3,
      word: [1, -2, 1, -2],
      knot: 'the figure eight',
      ways: 0,
      legal: 3,
      fewest: null,
      note: 'Hopeless, and the card at the end of the ask says so. Only 3 of '
          'the 81 paintings keep the rule, and all three paint the whole rope '
          'one colour. Suppose instead that every crossing showed three '
          'colours. The first two crossings both take arcs A and B, so the '
          'third arc at each is whichever colour is left over, which makes '
          'those two arcs the same. The third crossing wants those very two '
          'arcs different. So some crossing shows one colour, and one more '
          'crossing then paints the rest of the rope to match. Since the '
          'trefoil has 6 paintings and this has none, the two are not the '
          'same knot, however either is pulled about.',
    ),
  ];

  static int get count => all.length;

  static Level at(int number) => all[number];
}
