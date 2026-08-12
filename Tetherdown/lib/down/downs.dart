import 'down.dart';

/// The five downs that ship.
///
/// Every number here is checked before the bake: the census, the
/// pasture arithmetic and the sweep, and tool/check_downs.dart
/// refuses the lot if anything disagrees.
class Downs {
  static const all = [
    Down(
      name: 'The Square',
      posts: 4,
      asked: 4,
      ways: 3,
      note: 'Four posts hold four ropes at most, and only three '
          'tetherings reach it: each is the same square worn '
          'three ways, two pastures of two posts with every rope '
          'crossing between.',
    ),
    Down(
      name: 'The Five',
      posts: 5,
      asked: 5,
      ways: 72,
      note: 'One rope shy of the fence line leaves room: 72 of '
          'the 252 five-rope tetherings knot nothing.',
    ),
    Down(
      name: 'The Six',
      posts: 5,
      asked: 6,
      ways: 10,
      note: 'Six is the fence line for five posts, a quarter of '
          'twenty-five rounded down, and the ten tetherings that '
          'reach it all wear the same shape: pastures of two and '
          'three, every crossing roped.',
    ),
    Down(
      name: 'The Nine',
      posts: 6,
      asked: 9,
      ways: 10,
      note: 'Nine is the line for six posts, and the ten fullest '
          'tetherings are the ten ways of splitting six posts '
          'into pastures of three and three.',
    ),
    Down(
      name: 'The Seventh Rope',
      posts: 5,
      asked: 7,
      ways: 0,
      note: 'Two pastures of five posts hold six ropes at their '
          'best split, two times three, and that is all Mantel '
          'allows: the sweep tied all 120 seven-rope tetherings '
          'and every one knots a triangle.',
    ),
  ];

  static int get count => all.length;

  static Down at(int number) => all[number];
}
