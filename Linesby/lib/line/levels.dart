import 'level.dart';

/// The five asks, first to last. Every count is the sweep's, and the
/// checker refuses the bake if any drifts.
class Levels {
  static const all = <Level>[
    Level(
      name: 'The Right Angle',
      kind: 'right',
      ways: 2960,
      note: 'Of the 17,600 triangles on the field, 2,960 have a right angle, and '
          'in every one the orthocentre sits on the corner where it stands, '
          'the two sides there being altitudes themselves, while the '
          'circumcentre sits halfway along the side across, so the Euler '
          'line is the median from that corner. The three-peg corner (0, 0), '
          '(1, 0), (0, 1) is the first: G (1/3, 1/3), O (1/2, 1/2), H (0, 0).',
    ),
    Level(
      name: 'The Level Line',
      kind: 'level',
      ways: 486,
      note: '486 triangles of the 17,600 hold their three centres at one height, '
          '378 of them isosceles with a flat axis and 134 right-angled; (0, '
          '0), (4, 0), (1, 3) is the first, G (5/3, 1), O (2, 1), H (1, 1), '
          'the centroid a third of the way from O to H, as it always is.',
    ),
    Level(
      name: 'The Far Centre',
      kind: 'off',
      ways: 3656,
      note: 'The circumcentre falls off the field for 3,656 triangles of the '
          '17,600, every one obtuse: the flatter the triangle, the farther '
          'the centre. (0, 0), (1, 0), (4, 1) is the first, its centre just '
          'off the top at (1/2, 13/2), and (0, 0), (1, 1), (6, 5) sends it '
          'farthest, to (51/2, -49/2), with the orthocentre, A + B + C less '
          'twice O, flung to (-44, 55).',
    ),
    Level(
      name: 'The Whole Three',
      kind: 'whole',
      ways: 20,
      note: 'Twenty triangles of the 17,600 set all three centres on pegs, and '
          'every one of the twenty is right-angled; (0, 0), (6, 0), (3, 3) '
          'is the first, G (3, 1), O (3, 0), H (3, 3), and the right '
          'isosceles (0, 0), (6, 0), (0, 6) another, G (2, 2), O (3, 3), H '
          '(0, 0). The centroid alone lands on a peg for 1,716 triangles, the '
          'circumcentre for 2,428 and the orthocentre for 9,876.',
    ),
    Level(
      name: 'The One Point',
      kind: 'one',
      ways: 0,
      note: 'Hopeless, and the tile says so. One point for all three centres '
          'makes every median a perpendicular bisector, so each side equals '
          'its neighbours: an equilateral triangle, and none stands on pegs, '
          'since the tangent of the angle between two peg lines is a '
          'fraction while the tangent of sixty degrees is the square root of '
          'three, which is none. The sweep of all 17,600 finds none; the '
          'nearest is sides squared 17, 17 and 18, forty-four triangles such '
          'as (0, 0), (4, 1), (1, 4), whose centres G (5/3, 5/3), O (17/10, '
          '17/10), H (8/5, 8/5) still stand apart.',
    ),
  ];

  static int get count => all.length;

  static Level at(int number) => all[number];
}
