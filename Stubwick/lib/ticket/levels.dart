import 'level.dart';

/// The five asks, first to last. Every count is the sweep's, and the
/// checker refuses the bake if any drifts.
class Levels {
  static const all = <Level>[
    Level(
      name: 'The Check',
      kind: 'pass',
      ways: 10000,
      note: 'Of the 100,000 tickets, 10,000 pass, one for every run of the '
          'first four digits, since the check digit that brings the sum to '
          'a ten is one and only one; 4 9 9 2 4 adds 4, 9, 9, 4 and 4, '
          'thirty, and passes.',
    ),
    Level(
      name: 'The Swap Unseen',
      kind: 'swap',
      ways: 732,
      note: 'Swap two neighbouring digits of a passing ticket and it fails, '
          'unless they are 0 and 9: a digit doubled and one plain add the '
          'same either way round only for those two, and of the 36,000 '
          'swaps of unlike neighbours in passing tickets the sweep finds '
          '800 passing still, every one a 0 and a 9; 732 passing tickets '
          'hold such a pair.',
    ),
    Level(
      name: 'The Twin Slip',
      kind: 'twin',
      ways: 2132,
      note: 'A digit and its double add 0, 3, 6, 9, 2, 6, 9, 2, 5 and 8 by '
          'ten for 0 to 9, so 2 and 5 add alike, 3 and 6, and 4 and 7: turn '
          'a 22 to 55, or a 33 to 66, or a 44 to 77, or back, and the '
          'ticket passes still; of the 36,000 such turns of twin pairs in '
          'passing tickets 2,400 pass, 400 a kind, and no other twins do; '
          '2,132 passing tickets hold such a pair.',
    ),
    Level(
      name: 'The Palindrome',
      kind: 'palindrome',
      ways: 100,
      note: 'A ticket that reads the same backwards has the shape a b c b '
          'a, a thousand of them, and a hundred pass, one for every a and '
          'b, since c alone must then bring the sum to a ten; 0 0 0 0 0 is '
          'the first and the only passing ticket of one digit throughout.',
    ),
    Level(
      name: 'The Slip Unseen',
      kind: 'slip',
      ways: 0,
      note: 'Hopeless, and the tile says so. A slip in a plain place moves '
          'the sum by the difference of the two digits, one to nine, never '
          'a ten; and the doubling takes the ten digits to 0, 2, 4, 6, 8, '
          '1, 3, 5, 7 and 9, every digit once, so a slip in a doubled place '
          'moves the sum too, by a difference of two of those. Luhn patented '
          'the rule in 1960 for exactly this, and the sweep of all 450,000 '
          'single slips of the 10,000 passing tickets finds every one '
          'caught.',
    ),
  ];

  static int get count => all.length;

  static Level at(int number) => all[number];
}
