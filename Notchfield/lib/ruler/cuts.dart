import 'cut.dart';

/// The rulers that ship.
///
/// Every number here is checked twice over: tool/check_cuts.dart
/// sweeps every placing of the notches and refuses the bake on any
/// disagreement.
class Cuts {
  static const all = [
    Cut(
      name: 'The Three Notches',
      length: 3,
      notches: 3,
      perfect: true,
      ways: 2,
      note: 'Three notches on a three-length: one, two and three '
          'each measured once. Two cuttings do it, each the other '
          'turned end for end.',
    ),
    Cut(
      name: 'The Six Inches',
      length: 6,
      notches: 4,
      perfect: true,
      ways: 2,
      note: 'The old perfect ruler: four notches, six lengths, every '
          'one measured once. The sweep of all 35 placings finds the '
          'cutting and its mirror and nothing else.',
    ),
    Cut(
      name: 'The Twelve',
      length: 12,
      notches: 5,
      perfect: false,
      ways: 22,
      note: 'Five notches on a twelve, no length twice: room to '
          'breathe, and twenty two cuttings manage it.',
    ),
    Cut(
      name: 'The Eleven',
      length: 11,
      notches: 5,
      perfect: false,
      ways: 4,
      note: 'Five notches on an eleven, no length twice: four '
          'cuttings in all 792, two and their mirrors. A ten cannot '
          'do it at all, the sweep says, so eleven is the shortest '
          'field five notches can share.',
    ),
    Cut(
      name: 'The Perfect Ten',
      length: 10,
      notches: 5,
      perfect: false,
      ways: 0,
      note: 'Five notches measure ten pairs, and a ten-length has '
          'exactly ten lengths to give: no slack anywhere, so a sound '
          'cutting here would be perfect. The sweep of all 462 '
          'placings finds none, not one length-list without a '
          'repeat. Five notches simply do not fit a ten.',
    ),
  ];

  static int get count => all.length;

  static Cut at(int number) => all[number];
}
