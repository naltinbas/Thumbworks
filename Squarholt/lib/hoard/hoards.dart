import 'hoard.dart';

/// The five hoards that ship.
///
/// Every number here is checked before the bake: the writings
/// swept, the remainder law and Fermat's law held whole, the
/// old identity executed, and tool/check_hoards.dart refuses
/// the lot if anything disagrees.
class Hoards {
  static const all = [
    Hoard(
      name: 'The Five',
      target: 5,
      ways: 1,
      note: 'Five is the smallest hoard paid by two tiles of '
          'different sizes; two alone comes earlier, paid by '
          'twin ones.',
    ),
    Hoard(
      name: 'The Three and Four',
      target: 25,
      ways: 1,
      note: 'Three and four squared make five squared, the '
          'oldest right angle in the book, and twenty-five '
          'takes no other pair.',
    ),
    Hoard(
      name: 'The Half Hundred',
      target: 50,
      ways: 2,
      note: 'Both writings fall out of five times ten by the '
          'old identity, one per sign, and one of them is the '
          'twins, five and five.',
    ),
    Hoard(
      name: 'The Great Prime',
      target: 97,
      ways: 1,
      note: 'Every prime one past a four-times under a hundred '
          'writes exactly once, and ninety-seven is the last '
          'of them.',
    ),
    Hoard(
      name: 'The Forty-Three',
      target: 43,
      ways: 0,
      note: 'Both neighbours write, forty-one as sixteen and '
          'twenty-five, forty-five as nine and thirty-six; '
          'forty-three sits between them, three past a '
          'four-times, out of every reach.',
    ),
  ];

  static int get count => all.length;

  static Hoard at(int number) => all[number];
}
