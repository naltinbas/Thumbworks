import 'hand.dart';

/// The five hands that ship.
///
/// Every number here is checked before the bake: the sweep of
/// all 7,776 hands, the quantised count, the two-case argument,
/// and tool/check_thirds.dart refuses the lot if anything
/// disagrees.
class Hands {
  static const all = [
    Hand(
      name: 'The Four Thirds',
      asked: 4,
      opens: [1, 1, 1, 1, 1],
      ways: 5760,
      note: 'Four is the common lot: five thousand seven '
          'hundred and sixty of the 7,776 hands carry exactly '
          'four thirds.',
    ),
    Hand(
      name: 'The One Third',
      asked: 1,
      opens: [1, 1, 1, 1, 1],
      ways: 1920,
      note: 'One third is as few as any hand carries: the count '
          'never lands on two, three, nor five through nine, '
          'and never on nought at all.',
    ),
    Hand(
      name: 'The Perfect Ten',
      asked: 10,
      opens: [1, 2, 3, 4, 5],
      ways: 96,
      note: 'Ten happens exactly when every stone shares one '
          'remainder of three: all ten triples land together '
          'or they do not all land.',
    ),
    Hand(
      name: 'The Locked Six',
      asked: 1,
      opens: [6, 1, 1, 1, 1],
      locked: (0, 6),
      ways: 320,
      note: 'The held six changes nothing the law cares about: '
          'a six is a nought of threes, and the locked sweep '
          'still lands only one, four or ten.',
    ),
    Hand(
      name: 'The Empty Hand',
      asked: 0,
      opens: [1, 1, 1, 1, 1],
      ways: 0,
      note: 'Five stones cannot dodge it: either some remainder '
          'shows three times, and three of a kind sum to a '
          'three-times, or all three remainders show, and '
          'nought, one and two make three.',
    ),
  ];

  static int get count => all.length;

  static Hand at(int number) => all[number];
}
