import 'lighting.dart';

/// The five lightings that ship.
///
/// Every number here is checked before the bake: the sweep of every
/// lighting of the mere, the shapes counted, the three-light
/// argument run, and tool/check_lights.dart refuses the lot if
/// anything disagrees.
class Lightings {
  static const all = [
    Lighting(
      name: 'The Four Lights',
      count: 4,
      ways: 25,
      shapes: 2,
      note: 'Two shapes and no more: the block, a square of four, and '
          'the tub, four round an unlit middle; sixteen places for the '
          'block on the mere and nine for the tub.',
    ),
    Lighting(
      name: 'The Five Lights',
      count: 5,
      ways: 36,
      shapes: 4,
      note: 'One shape, the boat, a tub with one corner filled, lying '
          'four ways round and in nine places each.',
    ),
    Lighting(
      name: 'The Six Lights',
      count: 6,
      ways: 94,
      shapes: 14,
      note: 'Fourteen shapes lie still with six, the beehive, the ship, '
          'the barge, the snake, the carrier and their turnings, 94 '
          'lightings of the mere.',
    ),
    Lighting(
      name: 'The Seven Lights',
      count: 7,
      ways: 76,
      shapes: 20,
      note: 'Twenty shapes with seven, the loaf and the long boat among '
          'them, 76 lightings of the mere; fewer places than six, since '
          'the shapes are longer.',
    ),
    Lighting(
      name: 'The Three Lights',
      count: 3,
      ways: 0,
      shapes: 0,
      note: 'Every lit lantern needs two lit neighbours to stay, and '
          'with three lights that means all three touch: the sweep '
          'finds exactly 64 such lightings, every one three corners of '
          'a square, and in every one the fourth corner has three lit '
          'neighbours and lights.',
    ),
  ];

  static int get count => all.length;

  static Lighting at(int number) => all[number];
}
