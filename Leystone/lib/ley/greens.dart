import 'green.dart';

/// The five greens that ship.
///
/// Every number here is checked twice before the bake: the search
/// raises every ring of every green, and tool/check_greens.dart
/// refuses the lot if any count or label disagrees with it.
class Greens {
  static const all = [
    Green(
      name: 'The Close',
      size: 2,
      asked: 4,
      ways: 1,
      note: 'Every berth of the little close can hold: no three of '
          'its four corners share a line at all.',
    ),
    Green(
      name: 'The Six Stones',
      size: 3,
      asked: 6,
      ways: 2,
      note: 'Only two rings of six stand here, and each spares a '
          'whole diagonal of the green: the stones crowd everything '
          'but one slant.',
    ),
    Green(
      name: 'The Eight',
      size: 4,
      asked: 8,
      ways: 11,
      note: 'Two stones to every row and every column, and eleven '
          'rings of eight thread the slants.',
    ),
    Green(
      name: 'The Ten',
      size: 5,
      asked: 10,
      ways: 32,
      note: 'Thirty-two full rings of ten, and every one leaves the '
          'centre row and centre column holding exactly two like '
          'all the rest.',
    ),
    Green(
      name: 'The Odd Stone',
      size: 3,
      asked: 7,
      ways: 0,
      note: 'Seven stones on three rows put three in some row by '
          'plain counting, and a row is a ley: the search of every '
          'laying-out says the same, all thirty-six of them.',
    ),
  ];

  static int get count => all.length;

  static Green at(int number) => all[number];
}
