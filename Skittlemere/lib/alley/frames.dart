import 'frame.dart';

/// The alleys that ship.
///
/// Every number here is checked twice over: tool/check_frames.dart
/// recounts each alley and searches every position besides, and
/// refuses the bake on any disagreement.
class Frames {
  static const all = [
    Frame(
      name: 'The First Frame',
      rows: [5],
      count: 4,
      note: 'Five skittles count four, so the first knock can zero '
          'the alley: knock the middle one, and the two pairs left '
          'mirror each other.',
    ),
    Frame(
      name: 'The Two Rows',
      rows: [4, 7],
      count: 3,
      note: 'A four counts one and a seven counts two: three '
          'together, and the mover has it. The search of every '
          'position says the same.',
    ),
    Frame(
      name: 'The Long Frame',
      rows: [12],
      count: 4,
      note: 'Twelve in a row count four. The skittle arithmetic runs '
          'in a famous limp: the counts of single rows repeat with '
          'period twelve from seventy one on, and the suite recounts '
          'the stretch it ships.',
    ),
    Frame(
      name: 'The Three Frames',
      rows: [2, 3, 5],
      count: 5,
      note: 'Two, three and five count two, three and four, and '
          'added the carry-less way they make five: the mover has '
          'the alley, one right knock at a time.',
    ),
    Frame(
      name: 'The Even Alley',
      rows: [6, 6],
      count: 0,
      note: 'Two rows of six count nought together, and the house '
          'plays the mirror: whatever you knock in one row, it '
          'knocks the same in the other. Every knock of yours breaks '
          'the balance and every reply restores it, down to the last '
          'skittle, which is the house\'s. The search of every '
          'position agrees: the mover never has it.',
    ),
  ];

  static int get count => all.length;

  static Frame at(int number) => all[number];
}
