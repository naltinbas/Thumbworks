import 'level.dart';

/// The five asks that ship.
///
/// Every number here is checked before the bake: every setting of the
/// four loads swept with exact fractions, the equal loads swept apart,
/// and tool/check_loads.dart refuses the lot if anything disagrees.
class Levels {
  static const all = [
    Level(
      name: 'The Reversal',
      kind: 'behind',
      ways: 154,
      settings: 625,
      note: 'Ash cures the bigger share in spring, nine in ten to eight, and '
          'the bigger share in autumn, three in ten to two, and still the '
          'smaller share of the year whenever Ash\'s patients come mostly in '
          'autumn and Birch\'s mostly in spring: 154 settings of the 625 do it, '
          'the first with Ash seeing ten and ten and Birch thirty and ten, six '
          'in ten against thirteen in twenty.',
    ),
    Level(
      name: 'The Level Year',
      kind: 'level',
      ways: 24,
      settings: 625,
      note: 'Twenty-four settings make the two years the same share exactly, '
          'the first with Ash seeing ten and ten, twelve cured of twenty, and '
          'Birch twenty and ten, eighteen of thirty.',
    ),
    Level(
      name: 'The Wide Reversal',
      kind: 'far',
      ways: 17,
      settings: 625,
      note: 'Seventeen settings put Ash a fifth or more of the year behind: Ash '
          'seeing ten in spring and twenty in autumn cures fifteen of thirty, '
          'half, while Birch seeing fifty and ten cures forty-two of sixty, '
          'seven in ten.',
    ),
    Level(
      name: 'Ash Down to Two in Five',
      kind: 'low',
      ways: 25,
      settings: 625,
      note: 'Ash\'s year sinks to two in five exactly, and no lower, when Ash '
          'sees ten in spring and fifty in autumn, twenty-four cured of sixty; '
          'whatever Birch sees, twenty-five settings.',
    ),
    Level(
      name: 'The Reversal with Equal Loads',
      kind: 'behind',
      equalLoads: true,
      ways: 0,
      settings: 25,
      note: 'With both healers seeing the same number in each season, the year '
          'is the two seasons weighed alike for both, and Ash, one in ten '
          'ahead in each season, ends the year one in ten ahead exactly: of the '
          'twenty-five equal loads, none reverses, and every one of the 625 '
          'settings was swept to see that every reversal has the loads uneven.',
    ),
  ];

  static int get count => all.length;

  static Level at(int number) => all[number];
}
