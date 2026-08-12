import 'row.dart';

/// The five rows that ship.
///
/// Every number here is checked before the bake: the census, the
/// sweep and the prefix ledger, and tool/check_samplers.dart
/// refuses the lot if anything disagrees.
class Rows {
  static const all = [
    Row(
      name: 'The Six',
      stitches: 6,
      ways: 20,
      note: 'Six stitches leave room to wander: twenty of the 64 '
          'threadings hold no ladder.',
    ),
    Row(
      name: 'The Seven',
      stitches: 7,
      ways: 16,
      note: 'A seventh stitch thins the field to sixteen of 128. '
          'The three middle stitches each sit in five ladders\' '
          'reach and the ends in three, so the middle is where '
          'threadings go to die.',
    ),
    Row(
      name: 'The Eight',
      stitches: 8,
      ways: 6,
      note: 'Eight stitches leave exactly six threadings alive '
          'out of 256, and they pair off: three patterns and '
          'their thread-swaps, nothing else.',
    ),
    Row(
      name: 'The One Way',
      stitches: 8,
      fixed: ['R', 'R', 'B'],
      ways: 1,
      note: 'Three stitches fixed and the other five are forced '
          'to the last stitch: at eight, every beginning that '
          'can be finished can be finished exactly one way.',
    ),
    Row(
      name: 'The Ninth Stitch',
      stitches: 9,
      ways: 0,
      note: 'Van der Waerden\'s wall: the sweep threaded all 512 '
          'rows of nine and found a ladder in every one. Two '
          'threads cannot carry nine stitches, and no cleverness '
          'was ever going to help.',
    ),
  ];

  static int get count => all.length;

  static Row at(int number) => all[number];
}
