import 'quire.dart';

/// The six quires that ship.
///
/// Every number here is checked twice before the bake: the walk of
/// every weaving plays each quire out, and tool/check_quires.dart
/// refuses the lot if any count, word, or label disagrees with it.
class Quires {
  static const all = [
    Quire(
      name: 'The Second Leaf',
      start: [0, 1, 2, 3, 4, 5, 6, 7],
      seat: 1,
      weaves: 1,
      note: 'One in-weave lifts the under-stack\'s first leaf to the '
          'top seat, and the plate slips to second.',
    ),
    Quire(
      name: 'The Fifth Leaf',
      start: [0, 1, 2, 3, 4, 5, 6, 7],
      seat: 4,
      weaves: 3,
      note: 'An out-weave never moves the top leaf: only an in can '
          'begin the plate\'s journey.',
    ),
    Quire(
      name: 'The Seventh Leaf',
      start: [0, 1, 2, 3, 4, 5, 6, 7],
      seat: 6,
      weaves: 3,
      note: 'Even seats end their word on an out, odd seats on an '
          'in: the last figure of the seat says which.',
    ),
    Quire(
      name: 'The Great Quire',
      start: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15],
      seat: 11,
      weaves: 4,
      note: 'Sixteen leaves, and still no seat asks more than four '
          'weaves: as many as its figure has digits.',
    ),
    Quire(
      name: 'The Broken Stitch',
      start: [3, 1, 7, 5, 2, 0, 6, 4],
      home: true,
      weaves: 4,
      note: 'Three out-weaves alone bring a bound quire of eight '
          'back to itself, so out-weaves alone visit only three '
          'stacks from here, and none of them is home: this tangle '
          'needs the ins as well.',
    ),
    Quire(
      name: 'The Turned Pair',
      start: [0, 1, 2, 3, 4, 6, 5, 7],
      home: true,
      weaves: null,
      note: 'The weaves reach twenty-four stacks of a quire of '
          'eight, of the forty thousand there are, and this one is '
          'not among them.',
    ),
  ];

  static int get count => all.length;

  static Quire at(int number) => all[number];
}
