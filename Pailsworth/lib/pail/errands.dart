import 'errand.dart';

/// The errands that ship.
///
/// Every number here is checked twice over: tool/check_errands.dart
/// walks every waterline of each and refuses the bake if a written
/// figure is wrong, and the suite sweeps the shared-measure invariant
/// besides.
class Errands {
  static const all = [
    Errand(
      name: 'The First Fetch',
      caps: [6, 9],
      ask: 3,
      fewest: 2,
      note: 'Fill the nine and tip it into the six: what will not go '
          'is the three. Two pours, and the walk of every waterline '
          'finds nothing shorter.',
    ),
    Errand(
      name: 'The Springside Four',
      caps: [3, 5],
      ask: 4,
      fewest: 6,
      note: 'The famous one: four pints from a three and a five. Six '
          'pours, and the walk of all 24 waterlines says none of them '
          'was to spare.',
    ),
    Errand(
      name: 'The Six from Nine',
      caps: [4, 9],
      ask: 6,
      fewest: 8,
      note: 'A four and a nine make a six the long way round: eight '
          'pours, counted against every waterline there is.',
    ),
    Errand(
      name: 'The Even Hand',
      caps: [8, 5, 3],
      ask: 4,
      fewest: 6,
      note: 'The old decanting table: an eight, a five and a three. '
          'Four pints stand in six pours from dry, and the walk of '
          'all 216 waterlines holds the count.',
    ),
    Errand(
      name: 'The Long Errand',
      caps: [7, 11],
      ask: 2,
      fewest: 14,
      note: 'Two pints from a seven and an eleven, and no road there '
          'is short: fourteen pours, the longest errand on the shelf, '
          'and the walk says not one can be saved.',
    ),
    Errand(
      name: 'The Third Pint',
      caps: [6, 9],
      ask: 4,
      fewest: null,
      note: 'Six and nine share a measure of three, and every pour '
          'keeps every pail a multiple of it: the walk of every '
          'waterline finds nothing but noughts, threes, sixes and '
          'nines. Four is not among them, and never will be.',
    ),
  ];

  static int get count => all.length;

  static Errand at(int number) => all[number];
}
