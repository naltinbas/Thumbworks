import 'court.dart';

/// The five courts that ship.
///
/// Every number here is checked before the bake: the sweep at
/// every court, Golomb's quartering held to it on the four-court,
/// the studs counted on the five-court, and
/// tool/check_courts.dart refuses the lot if anything disagrees.
class Courts {
  static const all = [
    Court(
      name: 'The Corner Well',
      side: 4,
      wellX: 0,
      wellY: 0,
      ways: 1,
      note: 'The four-court paves round its corner well one way '
          'only, and Golomb\'s quartering lays that very paving: '
          'one elbow at the crossing, then one in each quarter.',
    ),
    Court(
      name: 'The Off Well',
      side: 4,
      wellX: 1,
      wellY: 2,
      ways: 1,
      note: 'Every one of the sixteen wells of the four-court '
          'paves, and every one paves exactly one way; the sweep '
          'found the sixteen pavings and the quartering built the '
          'same sixteen, elbow for elbow.',
    ),
    Court(
      name: 'The Wall Well',
      side: 5,
      wellX: 0,
      wellY: 2,
      ways: 16,
      note: 'A well halfway along a wall paves 16 ways; the four '
          'walls agree, and the four corners pave 8 ways apiece.',
    ),
    Court(
      name: 'The Middle Well',
      side: 5,
      wellX: 2,
      wellY: 2,
      ways: 32,
      note: 'The middle well paves 32 ways, the most of any well '
          'on the five-court, and its eight elbows cover the '
          'other eight studs, one apiece, in every one of them.',
    ),
    Court(
      name: 'The Stray Well',
      side: 5,
      wellX: 1,
      wellY: 2,
      ways: 0,
      note: 'Only the nine studs of the five-court are wells that '
          'pave, the sweep says, and the sixteen other wells '
          'pave nought ways each; seven elbows can be laid round '
          'the stray well, never eight.',
    ),
  ];

  static int get count => all.length;

  static Court at(int number) => all[number];
}
