import 'ferry.dart';

/// The ferries that ship.
///
/// Every number here is checked twice over: tool/check_ferries.dart
/// walks every arrangement of each and refuses the bake on any
/// disagreement.
class Ferries {
  static const all = [
    Ferry(
      name: 'The Keeper\'s Crossing',
      keeper: true,
      each: 0,
      capacity: 2,
      fewest: 7,
      reach: 10,
      note: 'The oldest ferry riddle in the book, told for twelve '
          'hundred years: wolf and goat, goat and cabbage, and only '
          'the keeper rows. Seven crossings, and the walk of every '
          'arrangement finds nothing shorter.',
    ),
    Ferry(
      name: 'The Three and Three',
      keeper: false,
      each: 3,
      capacity: 2,
      fewest: 11,
      reach: 64,
      note: 'Three missionaries, three cannibals, a boat for two, and '
          'no bank where the cannibals outnumber. Eleven crossings, '
          'none to spare.',
    ),
    Ferry(
      name: 'The Bigger Boat',
      keeper: false,
      each: 4,
      capacity: 3,
      fewest: 9,
      reach: 196,
      note: 'Four and four fit after all, given a boat for three: '
          'nine crossings, and the walk holds the count.',
    ),
    Ferry(
      name: 'The Five and Five',
      keeper: false,
      each: 5,
      capacity: 3,
      fewest: 11,
      reach: 624,
      note: 'Ten souls, a boat for three, eleven crossings: the walk '
          'stood on all 624 arrangements this river allows.',
    ),
    Ferry(
      name: 'The Four and Four',
      keeper: false,
      each: 4,
      capacity: 2,
      fewest: null,
      reach: 98,
      note: 'Four and four with a boat for two never land: the walk '
          'stood on all 98 arrangements a boat of two can reach, and '
          'the far bank is never full. Row as you like; the river '
          'keeps its half.',
    ),
  ];

  static int get count => all.length;

  static Ferry at(int number) => all[number];
}
