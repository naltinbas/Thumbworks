import 'level.dart';

/// The five asks, first to last. Every count is the sweep's, and the
/// checker refuses the bake if any drifts.
class Levels {
  static const all = <Level>[
    Level(
      name: 'The Twenty',
      number: 20,
      slots: 3,
      ways: 1,
      note: 'Twenty is 10 + 10 + 0 and nothing else from three heaps, and 10 '
          '+ 10 from two: one way of the 12 numbers to 500 with a single '
          'three-heap way, with 0, 1, 2, 4, 5, 8, 11, 14, 29, 50 and 53. '
          'Eight times twenty plus three is 163, which is 1 + 81 + 81, one '
          'way in odd squares to match.',
    ),
    Level(
      name: 'The Forty-Seven',
      number: 47,
      slots: 3,
      ways: 2,
      note: 'Forty-seven is 45 + 1 + 1 or 36 + 10 + 1, and it needs all '
          'three: no two triangular numbers make it. Eight times it plus '
          'three is 379, and 379 is 9 + 9 + 361 or 9 + 81 + 289, two ways in '
          'odd squares to match the two heaps.',
    ),
    Level(
      name: 'The Hundred',
      number: 100,
      slots: 3,
      ways: 6,
      note: 'A hundred is three heaps six ways: 55 + 45 + 0, 78 + 21 + 1, 91 '
          '+ 6 + 3, 66 + 28 + 6, 45 + 45 + 10 and 36 + 36 + 28. Of the '
          'numbers to 500, 406 has the most ways, sixteen, and every one of '
          'the 501 has at least one, as Gauss wrote in his diary in 1796: '
          'Eureka, num = triangle + triangle + triangle.',
    ),
    Level(
      name: 'The Twelve',
      number: 12,
      slots: 2,
      ways: 1,
      note: 'Twelve is 6 + 6 from two heaps, one way; from three it is 6 + 6 '
          '+ 0, 10 + 1 + 1 or 6 + 3 + 3. Two heaps miss 212 of the numbers '
          'to 500, 5, 8, 14, 17 and 19 first, and three heaps miss none.',
    ),
    Level(
      name: 'The Five',
      number: 5,
      slots: 2,
      ways: 0,
      note: 'Hopeless, and the tile says so. The triangular numbers below '
          'five are 0, 1 and 3, and their pairs add to 0, 1, 2, 3, 4 and 6: '
          'never five. Three heaps do it, 3 + 1 + 1, and 8 times 5 plus 3 is '
          '43, which is 9 + 9 + 25 in odd squares.',
    ),
  ];

  static int get count => all.length;

  static Level at(int number) => all[number];
}
