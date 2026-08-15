import 'level.dart';

/// The five frames that ship.
///
/// Every number here is checked before the bake: every laying of the
/// four pieces inside every frame swept, the areas held to Cassini's
/// identity, and tool/check_layings.dart refuses the lot if anything
/// disagrees.
class Levels {
  static const all = [
    Level(
      name: 'The Square',
      side: 8,
      width: 8,
      height: 8,
      overlapAllowed: 0,
      mustFill: false,
      ways: 16,
      layings: 9168384,
      note: 'The eight-square as it was cut: a strip three deep across the top '
          'split corner to corner into the two triangles, and the five deep '
          'below split by a slant into the two trapeziums. Sixteen layings of '
          'the 9,168,384 put it back, the strip at any of the four sides and '
          'either cut leaning either way.',
    ),
    Level(
      name: 'The Frame',
      side: 8,
      width: 13,
      height: 5,
      overlapAllowed: 0,
      mustFill: false,
      ways: 2,
      layings: 6533136,
      note: 'A triangle in the bottom left, a trapezium against it, the other '
          'two turned about in the top right, and a slant that seems to run '
          'corner to corner: two layings of the 6,533,136 lie inside with no '
          'overlap, one the other turned about, and each leaves a sliver of one '
          'square bare along the slant, since sixty-four squares of pieces lie '
          'in a frame of sixty-five.',
    ),
    Level(
      name: 'The Small Square',
      side: 5,
      width: 5,
      height: 5,
      overlapAllowed: 0,
      mustFill: false,
      ways: 16,
      layings: 1267776,
      note: 'The five-square cut the same way, a strip two deep and a slant '
          'through the three below: sixteen layings of the 1,267,776 put it '
          'back.',
    ),
    Level(
      name: 'The Small Frame',
      side: 5,
      width: 8,
      height: 3,
      overlapAllowed: 1,
      mustFill: false,
      ways: 2,
      layings: 559488,
      note: 'Twenty-five squares of pieces in a frame of twenty-four: they '
          'must overlap by a square at least, and two layings of the 559,488 '
          'overlap by exactly one, a sliver along the slant, one the other '
          'turned about; no laying lies inside with no overlap at all.',
    ),
    Level(
      name: 'The Frame Filled',
      side: 8,
      width: 13,
      height: 5,
      overlapAllowed: 0,
      mustFill: true,
      ways: 0,
      layings: 6533136,
      note: 'The frame is thirteen by five, sixty-five squares, and the four '
          'pieces have sixty-four between them, two triangles of twelve and two '
          'trapeziums of twenty; laid inside with no overlap they leave one '
          'square bare, and it is a sliver along the slant, since the triangle '
          'rises three in eight, the trapezium two in five and the frame corner '
          'to corner five in thirteen, no two the same. Of the 6,533,136 '
          'layings none fills it.',
    ),
  ];

  static int get count => all.length;

  static Level at(int number) => all[number];
}
