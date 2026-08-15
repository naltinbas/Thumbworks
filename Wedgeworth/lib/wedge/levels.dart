import 'level.dart';

/// The five asks, the last of them hopeless.
class Levels {
  static const all = [
    Level(
      name: 'The Three-Sided',
      kind: 'faces',
      sides: 3,
      ways: 3,
      note: 'A triangle\'s corner is 60 degrees, so three, four and five of them '
          'come to 180, 240 and 300, all under the full turn, and close the '
          'tetrahedron, the octahedron and the icosahedron; six make 360 exactly '
          'and lie flat, the triangle tiling.',
    ),
    Level(
      name: 'The Cube',
      kind: 'faces',
      sides: 4,
      ways: 1,
      note: 'A square\'s corner is 90 degrees: three make 270 and close the cube, '
          'six faces, twelve edges and eight corners by Euler\'s count, and four '
          'make 360 and lie flat, the square tiling.',
    ),
    Level(
      name: 'The Twelve',
      kind: 'faces',
      sides: 5,
      ways: 1,
      note: 'A pentagon\'s corner is 108 degrees: three make 324, leaving 36, and '
          'close the dodecahedron, twelve faces, thirty edges and twenty corners; '
          'four make 432 and overlap.',
    ),
    Level(
      name: 'The Twenty',
      kind: 'solid',
      faceCount: 20,
      ways: 1,
      note: 'Only five triangles to a corner make a solid of twenty faces, the '
          'icosahedron, with thirty edges and twelve corners; five squares or '
          'pentagons overlap, 450 and 540 degrees, and Euler\'s count for them '
          'is no number at all.',
    ),
    Level(
      name: 'The Honeycomb Corner',
      kind: 'faces',
      sides: 6,
      ways: 0,
      note: 'A hexagon\'s corner is 120 degrees: three make the full 360 and lie '
          'flat, as the bees\' comb does, and four or more overlap; no corner of '
          'hexagons closes, on the sham or anywhere, since three faces are the '
          'fewest a corner can have.',
    ),
  ];

  static int get count => all.length;

  static Level at(int i) => all[i];
}
