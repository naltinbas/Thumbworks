import 'lawn.dart';

/// The five lawns that ship.
///
/// Every number here is checked before the bake: the census, the
/// doubling and the sweep, and tool/check_lawns.dart refuses the
/// lot if anything disagrees.
class Lawns {
  static const all = [
    Lawn(
      name: 'The Two Odd',
      guests: 4,
      asked: 2,
      ways: 48,
      note: 'One shake does it, and 48 of the 64 lawns of four '
          'sit so: the commonest count by far.',
    ),
    Lawn(
      name: 'The Quiet Lawn',
      guests: 4,
      asked: 0,
      ways: 8,
      note: 'Eight lawns of four keep everyone even-handed, and '
          'eight is two to the third: one for every choice over '
          'the three shakes a spanning of the guests leaves '
          'spare.',
    ),
    Lawn(
      name: 'The Four Odd',
      guests: 5,
      asked: 4,
      ways: 320,
      note: 'Four of five odd-handed leaves one guest even, and '
          '320 of the 1,024 lawns manage it: five choices of the '
          'even guest, sixty-four lawns apiece.',
    ),
    Lawn(
      name: 'The Even Sixty-Four',
      guests: 5,
      asked: 0,
      ways: 64,
      note: 'The all-even lawns of five number 64, two to the '
          'sixth, one for every choice over the six shakes '
          'beyond a spanning: even-handedness is a loop of '
          'shakes, and loops stack freely.',
    ),
    Lawn(
      name: 'The Odd Guest',
      guests: 4,
      asked: 1,
      ways: 0,
      note: 'Every shake hands out exactly two, so the hand '
          'total is even, and an odd crowd of odd-handed guests '
          'would make it odd: exactly one is nobody\'s lawn. The '
          'sweep laid all 64 and the odd counts came 8, none, '
          '48, none, 8.',
    ),
  ];

  static int get count => all.length;

  static Lawn at(int number) => all[number];
}
