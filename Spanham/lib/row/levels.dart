import 'level.dart';

/// The shelves that ship.
///
/// Three and four set easily; seven and eight are the real mornings, with
/// dozens and hundreds of settings that are still hard to find by hand.
/// The five-pair shelf cannot be set at all, and the proof is arithmetic
/// on the seat numbers, done in the why for this exact shelf: no search,
/// no faith, a sum that comes out odd.
class Levels {
  const Levels._();

  static final List<Level> all = [
    Level(
      name: 'The Three Pairs',
      pairs: 3,
      possible: true,
      ways: 2,
      note: 'Two settings, and they are each other\'s mirror: really one '
          'way, read from either end.',
    ),
    Level(name: 'The Four Pairs', pairs: 4, possible: true, ways: 2),
    Level(
      name: 'The Five Pairs',
      pairs: 5,
      possible: false,
      ways: 0,
      note: 'Ten seats add to fifty five. Each pair of k sits at seats '
          'adding to twice-something plus k plus one, so the whole shelf '
          'adds to an even number plus twenty. Fifty five minus twenty is '
          'thirty five, odd: no setting exists, and no search was needed '
          'to know it.',
    ),
    Level(
      name: 'The Seven Pairs',
      pairs: 7,
      possible: true,
      ways: 52,
      note: 'Fifty two settings among over a hundred thousand ways to '
          'try: real room to move, and still easy to strand.',
    ),
    Level(name: 'The Eight Pairs', pairs: 8, possible: true, ways: 300),
  ];

  static int get count => all.length;

  static Level at(int number) => all[number.clamp(0, all.length - 1)];
}
