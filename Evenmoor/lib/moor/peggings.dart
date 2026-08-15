import 'pegging.dart';

/// The five peggings that ship.
///
/// Every number here is checked before the bake: the sweep of every
/// placing, the pigeonhole count held to the census on each, and
/// tool/check_halfways.dart refuses the lot if anything disagrees.
class Peggings {
  static const all = [
    Pegging(
      name: 'The Four Apart',
      pegs: 4,
      asked: 0,
      ways: 1296,
      placings: 12650,
      note: 'Four pegs keep every post off a hole only when they take '
          'one kind of hole each, even-even, odd-even, even-odd and '
          'odd-odd: 9 times 6 times 6 times 4 is 1,296 of the 12,650.',
    ),
    Pegging(
      name: 'The Three Together',
      pegs: 3,
      asked: 3,
      ways: 128,
      placings: 2300,
      note: 'Three pegs land all three posts only when they are all of '
          'one kind: 84 threes of the nine even-even holes, 20 and 20 of '
          'the six-hole kinds, 4 of the odd-odd four, 128 of the 2,300.',
    ),
    Pegging(
      name: 'The One Halfway',
      pegs: 5,
      asked: 1,
      ways: 13608,
      placings: 53130,
      note: 'Five pegs land one post at the least, never none: 13,608 '
          'placings of the 53,130 land exactly one, two pegs of one kind '
          'and one each of the other three.',
    ),
    Pegging(
      name: 'The Ten',
      pegs: 5,
      asked: 10,
      ways: 138,
      placings: 53130,
      note: 'All ten posts land only when the five pegs are all of one '
          'kind: 126 fives of the even-even nine and 6 each of the two '
          'six-hole kinds, 138 in all; the odd-odd kind has only four '
          'holes.',
    ),
    Pegging(
      name: 'The Five Apart',
      pegs: 5,
      asked: 0,
      ways: 0,
      placings: 53130,
      note: 'Four kinds of hole and five pegs: two pegs share a kind, so '
          'both are even across or both odd, both even down or both odd, '
          'and halfway between them is whole both ways; the sweep of all '
          '53,130 placings finds one post landed at the least.',
    ),
  ];

  static int get count => all.length;

  static Pegging at(int number) => all[number];
}
