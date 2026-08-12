import 'flock.dart';

/// The five flocks that ship.
///
/// Every number here is checked before the bake: the sweep of
/// all 8, 64 and 1,024 peckings, both crown counts on each, and
/// tool/check_pecks.dart refuses the lot if anything disagrees.
class Flocks {
  static const all = [
    Flock(
      name: 'The Round of Three',
      chickens: 3,
      asked: 3,
      ways: 2,
      note: 'Only the two round-robins crown all three; the '
          'other six peckings crown an emperor and him alone.',
    ),
    Flock(
      name: 'The Three of Four',
      chickens: 4,
      asked: 3,
      ways: 32,
      note: 'The sixty-four peckings of four split clean in '
          'half, thirty-two lone emperors and thirty-two courts '
          'of three, and a full court of four is nothing at '
          'all: no pecking of four crowns everybody.',
    ),
    Flock(
      name: 'The Four of Five',
      chickens: 5,
      asked: 4,
      ways: 120,
      note: 'A lone king is always an emperor: were anyone '
          'pecking him, that little flock would keep a king of '
          'its own, and the crown would double.',
    ),
    Flock(
      name: 'The Full Court',
      chickens: 5,
      asked: 5,
      ways: 64,
      note: 'The busiest pecker is crowned in every pecking '
          'there is: to go uncrowned he would need an outpecker '
          'pecking him and all he pecks, one more than his own '
          'count.',
    ),
    Flock(
      name: 'The Pair of Kings',
      chickens: 4,
      asked: 2,
      ways: 0,
      note: 'Beside the pair, four chickens wear every count '
          'they can: thirty-two lone crowns, thirty-two courts '
          'of three, and never a four either, though five '
          'chickens manage all five counts but two.',
    ),
  ];

  static int get count => all.length;

  static Flock at(int number) => all[number];
}
