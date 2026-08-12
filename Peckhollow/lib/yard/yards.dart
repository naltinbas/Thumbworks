import 'yard.dart';

/// The five yards that ship.
///
/// Every number here is checked twice before the bake: the sweep
/// flips through every yard, and tool/check_yards.dart refuses the
/// lot if any count, par, or label disagrees with it.
class Yards {
  static const all = [
    Yard(
      name: 'The Three',
      birds: 3,
      start: 7,
      wantCount: 3,
      par: 1,
      note: 'One flip turns the pecking order into a ring of '
          'three, and a ring is all kings: each pecks the next and '
          'reaches the last through it. The only three-bird yards '
          'that crown all three are the two rings.',
    ),
    Yard(
      name: 'The Bantam',
      birds: 4,
      start: 63,
      wantOnly: 3,
      par: 3,
      note: 'The bantam starts pecked by every bird in the yard; '
          'three flips are the fewest that leave it the only '
          'crown, and the sweep of every flipping knows.',
    ),
    Yard(
      name: 'The Three Crowns',
      birds: 5,
      start: 1023,
      wantCount: 3,
      par: 1,
      note: 'Of the 1,024 yards of five, 520 crown exactly three: '
          'the commonest crowning there is.',
    ),
    Yard(
      name: 'The Full Court',
      birds: 5,
      start: 1023,
      wantCount: 5,
      par: 2,
      note: 'Sixty-four yards of the 1,024 crown all five, and '
          'none of them is nearer the pecking order than two '
          'flips.',
    ),
    Yard(
      name: 'The Two Kings',
      birds: 4,
      start: 63,
      wantCount: 2,
      par: null,
      note: 'A yard of four crowns one or three: thirty-two yards '
          'each way of the sixty-four, none with two and none with '
          'all four.',
    ),
  ];

  static int get count => all.length;

  static Yard at(int number) => all[number];
}
