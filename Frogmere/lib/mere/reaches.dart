import 'reach.dart';

/// The five reaches that ship.
///
/// Every number here is checked before the bake: the roads and
/// the fewest leaps counted, the weights added up exactly, and
/// tool/check_reaches.dart refuses the lot if anything disagrees.
class Reaches {
  static const all = [
    Reach(
      name: 'The First Reach',
      reach: 1,
      army: [(0, 0), (0, -1)],
      roads: 1,
      leaps: 1,
      note: 'Two frogs weigh exactly one against the first reach, '
          'one over phi and one over phi squared, so the one leap '
          'keeps the weight whole and lands.',
    ),
    Reach(
      name: 'The Second Reach',
      reach: 2,
      army: [(0, -1), (0, 0), (1, 0), (2, 0)],
      roads: 1,
      leaps: 3,
      note: 'Four frogs weigh exactly one against the second reach '
          'and three frogs cannot: the three heaviest pads below '
          'the reeds weigh 0.854 together, and no leap gains.',
    ),
    Reach(
      name: 'The Third Reach',
      reach: 3,
      army: [(-2, 0), (-1, 0), (0, -3), (0, -2), (0, -1), (0, 0), (1, 0), (2, 0)],
      roads: 8,
      leaps: 7,
      note: 'Eight frogs weigh exactly one against the third reach, '
          'and seven cannot: the seven heaviest pads weigh 0.944. '
          'Eight roads land, every one of them seven leaps and '
          'every leap toward the aim.',
    ),
    Reach(
      name: 'The Fourth Reach',
      reach: 4,
      army: [
        (-2, -2), (-2, -1), (-2, 0),
        (-1, -2), (-1, -1), (-1, 0),
        (0, -3), (0, -2), (0, -1), (0, 0),
        (1, -3), (1, -2), (1, -1), (1, 0),
        (2, -2), (2, -1), (2, 0),
        (3, -2), (3, 0), (4, 0),
      ],
      roads: 369106018,
      leaps: 19,
      note: 'These twenty frogs weigh exactly one against the fourth '
          'reach, so every road uses every frog and every leap is '
          'toward the aim: nineteen leaps, in 369,106,018 orders. '
          'Nineteen frogs never get there: the nineteen heaviest '
          'pads weigh exactly one, so such an army would have to be '
          'those very pads and leap perfectly, and the count of '
          'every one of the 84 such armies finds no road.',
    ),
    Reach(
      name: 'The Fifth Reach',
      reach: 5,
      army: [
        (-4, 0), (-3, 0), (-2, 0), (-1, 0), (0, 0), (1, 0), (2, 0), (3, 0), (4, 0),
        (-4, -1), (-3, -1), (-2, -1), (-1, -1), (0, -1), (1, -1), (2, -1), (3, -1), (4, -1),
        (-4, -2), (-3, -2), (-2, -2), (-1, -2), (0, -2), (1, -2), (2, -2), (3, -2), (4, -2),
      ],
      roads: 0,
      leaps: 0,
      note: 'These twenty-seven frogs weigh 0.679 against the fifth '
          'reach, and the whole pond below the reeds, every pad of '
          'it out to the edge of the world, weighs exactly one: no '
          'army you could set down reaches, whatever its size.',
    ),
  ];

  static int get count => all.length;

  static Reach at(int number) => all[number];
}
