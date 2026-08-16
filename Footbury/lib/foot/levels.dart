import 'level.dart';

/// The five asks, first to last. Every count is the sweep's, and the
/// checker refuses the bake if any drifts.
class Levels {
  static const all = <Level>[
    Level(
      name: 'The Quarter',
      kind: 'quarter',
      ways: 220,
      note: 'The feet of the middle of the circle are the middles of the '
          'three sides, and their triangle is a quarter of the whole, for '
          'every one of the 220 triangles on the rim: Euler\'s rule gives '
          'the square of the radius, 25, less nought, over four times 25.',
    ),
    Level(
      name: 'The Fifth',
      kind: 'fifth',
      ways: 1760,
      note: 'The feet\'s triangle is a fifth of the whole when the point '
          'stands root five from the middle, at (1, 2), (2, 1) or any of '
          'the eight such points, since 25 less 5 over 100 is a fifth: '
          '1,760 settings, eight for every triangle. Twenty different '
          'shares come in all, from a quarter at the middle to minus a '
          'quarter at the field\'s corners, where the point is root fifty '
          'out and the feet turn the other way round.',
    ),
    Level(
      name: 'The Middle Line',
      kind: 'middle',
      ways: 156,
      note: 'With the point on the rim the feet lie in a line, Simson\'s, '
          'and on 156 of the 1,980 rim settings the line runs through the '
          'middle of the circle: the triangle (5, 0), (4, 3), (-5, 0) with '
          'the point (0, -5) is the first.',
    ),
    Level(
      name: 'The Level Line',
      kind: 'level',
      ways: 114,
      note: 'Simson\'s line lies level on 114 rim settings, and along one '
          'of the triangle\'s own sides on 540, which happens when the '
          'point is opposite a corner across the middle, its foot on that '
          'corner\'s far side; the triangle (5, 0), (4, 3), (3, 4) with '
          'the point (0, 5) drops a level line.',
    ),
    Level(
      name: 'The Line Off the Rim',
      kind: 'off',
      ways: 0,
      note: 'Hopeless, and the tile says so. The feet\'s triangle is to the '
          'whole as the square of the radius less the square of the '
          'point\'s distance from the middle is to four times the square '
          'of the radius, Euler\'s rule of 1763, so it shrinks to nothing, '
          'the feet in a line, exactly when the point stands a radius from '
          'the middle, on the rim: Wallace\'s theorem of 1799, carried '
          'under Simson\'s name. The sweep of all 25,960 settings, 220 '
          'triangles and 118 points each, finds the feet in a line on the '
          '1,980 rim settings and on none of the 23,980 others.',
    ),
  ];

  static int get count => all.length;

  static Level at(int number) => all[number];
}
