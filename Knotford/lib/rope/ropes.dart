import 'rope.dart';

/// The five ropes that ship.
///
/// Every number here is checked before the bake: the sweep of every
/// marking, Euclid's formula held to it, and tool/check_ropes.dart
/// refuses the lot if anything disagrees.
class Ropes {
  static const all = [
    Rope(
      name: 'The Twelve',
      knots: 12,
      ways: 6,
      markings: 55,
      note: 'The rope-stretchers\' rope: 3, 4 and 5 gaps, since 9 and 16 make '
          '25, and the corner between the 3 and the 4 is square. Six of the '
          '55 markings run those sides round the pegs one order or another, '
          'and no shorter rope squares at all.',
    ),
    Rope(
      name: 'The Thirty',
      knots: 30,
      ways: 6,
      markings: 406,
      note: '5, 12 and 13: 25 and 144 make 169. It is Euclid\'s with m 3 and '
          'n 2, and the only right triangle of thirty gaps; six of the 406 '
          'markings run it.',
    ),
    Rope(
      name: 'The Forty',
      knots: 40,
      ways: 6,
      markings: 741,
      note: '8, 15 and 17: 64 and 225 make 289, Euclid\'s with m 4 and n 1. '
          'The 3, 4, 5 rope doubled and trebled needs 24 and 36 knots, so '
          'forty has this triangle alone, six markings of the 741.',
    ),
    Rope(
      name: 'The Sixty',
      knots: 60,
      ways: 12,
      markings: 1711,
      note: 'Two triangles share the sixty: 10, 24, 26, which is 5, 12, 13 '
          'doubled, and 15, 20, 25, which is 3, 4, 5 five times over. Twelve '
          'of the 1,711 markings square the corner, six for each.',
    ),
    Rope(
      name: 'The Odd Rope',
      knots: 25,
      ways: 0,
      markings: 276,
      note: 'A square leaves nought or one when divided by four, so two '
          'squares adding to a third fix which sides are odd: either both '
          'short sides are even, or one short side and the long one are '
          'odd. Either way the three sides add up even, and a rope of '
          'twenty-five knots never squares; nor does any odd rope, swept to '
          'two hundred.',
    ),
  ];

  static int get count => all.length;

  static Rope at(int number) => all[number];
}
