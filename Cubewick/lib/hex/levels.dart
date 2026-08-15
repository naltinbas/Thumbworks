import 'level.dart';

/// The five hexagons that ship.
///
/// Every number here is checked before the bake: every tiling swept,
/// MacMahon's product and the stacks of cubes held to the sweep, and
/// tool/check_tilings.dart refuses the lot if anything disagrees.
class Levels {
  static const all = [
    Level(
      name: 'The One Box',
      a: 1,
      b: 1,
      c: 1,
      ways: 2,
      note: 'Six triangles, three lozenges, and two tilings: the three '
          'lozenges meet at the middle one way or the other, and read as an '
          'empty box or a box with one cube in it.',
    ),
    Level(
      name: 'The Flat Box',
      a: 2,
      b: 2,
      c: 1,
      ways: 6,
      note: 'Sixteen triangles and eight lozenges; six tilings, which is the '
          'six ways of setting cubes one high on a two-by-two floor with none '
          'set unless the ones nearer the back corner are: no cube, one in the '
          'corner, two along either wall, three, or all four. MacMahon\'s '
          'product says 2/1 times 3/2 times 3/2 times 4/3, which is 6.',
    ),
    Level(
      name: 'The Two Box',
      a: 2,
      b: 2,
      c: 2,
      ways: 20,
      note: 'Twenty-four triangles, twelve lozenges, twenty tilings, and '
          'twenty stacks of cubes in the two-by-two-by-two box, from the empty '
          'box to the full one.',
    ),
    Level(
      name: 'The Long Box',
      a: 2,
      b: 3,
      c: 3,
      ways: 175,
      note: 'Forty-two triangles, twenty-one lozenges and 175 tilings, the '
          'same as the stacks in a two-by-three-by-three box; the three-by-'
          'three-by-three has 980 and the four-box 232,848, all three counts '
          'agreeing.',
    ),
    Level(
      name: 'The Chipped Box',
      a: 2,
      b: 2,
      c: 2,
      chipped: [(true, 0, 0), (true, 0, 3)],
      ways: 0,
      note: 'Every lozenge is one triangle pointing up glued to one pointing '
          'down, so a tiling needs as many of one as the other. The two-box '
          'has twelve and twelve; chip two up-pointing triangles out and ten '
          'face twelve, so two down-pointing ones are always left bare.',
    ),
  ];

  static int get count => all.length;

  static Level at(int number) => all[number];
}
