import 'cording.dart';

/// The five cordings that ship.
///
/// Every number here is checked before the bake: the sweep of every
/// three and four of the twelve, Thales' reading held to the corner
/// test on every triangle, and tool/check_wheels.dart refuses the
/// lot if anything disagrees.
class Cordings {
  static const all = [
    Cording(
      name: 'The Right Corner',
      asked: Asked.rightCorner,
      given: [],
      pegs: 3,
      ways: 60,
      sets: 220,
      note: 'Sixty of the 220 triangles have a square corner: six '
          'diameters, and ten other pegs to sit the corner on for each.',
    ),
    Cording(
      name: 'The Sharp Three',
      asked: Asked.sharpThree,
      given: [],
      pegs: 3,
      ways: 40,
      sets: 220,
      note: 'Forty triangles are sharp at every corner, sixty have a '
          'square one and a hundred and twenty a blunt one: sharp all '
          'round means the hub inside.',
    ),
    Cording(
      name: 'The Square Wheel',
      asked: Asked.squareWheel,
      given: [],
      pegs: 4,
      ways: 3,
      sets: 495,
      note: 'Three squares stand on the twelve pegs, one on the spokes '
          'and two turned, of the 495 fours; each is two diameters '
          'crossing square.',
    ),
    Cording(
      name: 'The Given Two',
      asked: Asked.givenTwo,
      given: [(5, 0), (0, 5)],
      pegs: 3,
      ways: 2,
      sets: 10,
      note: 'The two given are not across from one another, so the '
          'square corner must sit on one of them, and the third peg is '
          'the peg across from the other: two of the ten.',
    ),
    Cording(
      name: 'The Off Diameter',
      asked: Asked.offDiameter,
      given: [],
      pegs: 3,
      ways: 0,
      sets: 220,
      note: 'Every one of the sixty square corners on the wheel looks '
          'across at a diameter, and none of the other 160 triangles has '
          'a square corner at all: Thales, both ways, on all 220.',
    ),
  ];

  static int get count => all.length;

  static Cording at(int number) => all[number];
}
