import 'dart:io';

import 'package:shelfham/shelf/rules.dart';
import 'package:shelfham/shelf/shelves.dart';

/// Reads every step, runs the recurrence, reverses every order,
/// and refuses the bake on any disagreement: this is what
/// `make shelves` runs, and the README quotes its ledger verbatim.
void main() {
  // The sweep against the recurrence and the reversal, every
  // size shipped.
  for (final books in [4, 5]) {
    final rules = Rules(books);
    for (var steps = 0; steps < books; steps++) {
      if (rules.waysTo(steps) != Rules.eulerian(books, steps)) {
        stderr.writeln('EULER PARTED AT $books, $steps');
        exit(1);
      }
    }
    if (!rules.reversalPairs()) {
      stderr.writeln('A SHELF THAT READS DIFFERENTLY BACKWARDS '
          'AT $books');
      exit(1);
    }
  }

  for (final shelf in Shelves.all) {
    final ways = Rules(shelf.books).waysTo(shelf.asked);
    if (ways != shelf.ways) {
      stderr.writeln('${shelf.name}: sweep finds $ways, '
          'label says ${shelf.ways}');
      exit(1);
    }
  }

  // The note-claims, each recomputed.
  final four = Rules(4);
  if ('${[for (var k = 0; k < 4; k++) four.waysTo(k)]}' !=
      '[1, 11, 11, 1]') {
    stderr.writeln('THE ROW OF FOUR MOVED');
    exit(1);
  }
  final five = Rules(5);
  if ('${[for (var k = 0; k < 5; k++) five.waysTo(k)]}' !=
      '[1, 26, 66, 26, 1]') {
    stderr.writeln('THE ROW OF FIVE MOVED');
    exit(1);
  }
  if (four.waysTo(4) != 0) {
    stderr.writeln('A FOURTH STEP APPEARED');
    exit(1);
  }

  stdout.writeln(
      'every ordering of every shelf swept, 24 and 120 by size: '
      'the step counts match Euler\'s recurrence entry for '
      'entry, every shelf read backwards swaps its steps for '
      'the gaps left over, and the rows run 1, 11, 11, 1 and '
      '1, 26, 66, 26, 1 with nothing past the last gap');
  stdout.writeln('');

  for (var number = 0; number < Shelves.count; number++) {
    final shelf = Shelves.at(number);
    final name = shelf.name.padRight(16);
    stdout.writeln(shelf.winnable
        ? ' ${number + 1} $name ${shelf.task}: ${shelf.ways} '
            'ordering${shelf.ways == 1 ? '' : 's'} of the sweep '
            'land${shelf.ways == 1 ? 's' : ''} it'
        : ' ${number + 1} $name ${shelf.task}: none of the 24, '
            'since four steps want a fifth book');
  }
}
