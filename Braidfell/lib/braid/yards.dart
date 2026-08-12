import 'yard.dart';

/// The five yards that ship.
///
/// Every number here is checked twice before the bake: the
/// lightest-first rule and the sweep of every order are held
/// against each other, and tool/check_yards.dart refuses the lot if
/// anything disagrees.
class Yards {
  static const all = [
    Yard(
      name: 'The Three Fleeces',
      bundles: [1, 2, 3],
      asked: 9,
      least: 9,
      note: 'Three bundles braid three ways, costing 9, 10 and 11: '
          'only lightest-first lands the nine.',
    ),
    Yard(
      name: 'The Even Four',
      bundles: [1, 1, 1, 1],
      asked: 8,
      least: 8,
      note: 'Even weights still leave a wrong turn: braid a pair '
          'with a single and the yard runs to nine. Eight needs '
          'the two pairs braided first.',
    ),
    Yard(
      name: 'The Doubles',
      bundles: [1, 2, 4, 8, 16],
      asked: 56,
      least: 56,
      note: 'Each bundle outweighs everything below it put '
          'together, so the cheap braid is a chain from the '
          'bottom: 56 against a dearest order of 113.',
    ),
    Yard(
      name: 'The Primes',
      bundles: [2, 3, 5, 7, 11],
      asked: 60,
      least: 60,
      note: 'A hundred and eighty orders run from 60 to 95, and '
          'the sixty is lightest-first\'s alone.',
    ),
    Yard(
      name: 'The Fifty-Nine',
      bundles: [2, 3, 5, 7, 11],
      asked: 59,
      least: 60,
      note: 'The same five bundles, one pound less asked: the '
          'sweep of all 180 orders bottoms out at sixty, and '
          'fifty-nine was never on the table.',
    ),
  ];

  static int get count => all.length;

  static Yard at(int number) => all[number];
}
