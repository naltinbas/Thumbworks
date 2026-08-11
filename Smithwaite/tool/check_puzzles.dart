// A command line tool whose whole job is to print. It is not part of any game.
// ignore_for_file: avoid_print

import 'package:smithwaite/forge/fewest.dart';
import 'package:smithwaite/forge/puzzles.dart';

/// Walks every shipped puzzle and prints the ledger the README quotes.
///
/// Run with: dart run tool/check_puzzles.dart  (or `make rings`)
void main() {
  // The two answers first, on every state there is at nine rings.
  final far = Moves.walk(9);
  for (var state = 0; state < (1 << 9); state++) {
    if (far[state] != Moves.bySmith(9, state)) {
      throw StateError('walk and smith part at $state');
    }
  }
  print('the walk and the smith agree on every state of nine rings: '
      '${1 << 9} states\n');

  var wrong = 0;
  for (var number = 0; number < Puzzles.count; number++) {
    final puzzle = Puzzles.at(number);
    final walk = Moves.walk(puzzle.rings)[puzzle.start];
    final smith = Moves.bySmith(puzzle.rings, puzzle.start);

    final agree = walk == puzzle.fewest && smith == puzzle.fewest;
    if (!agree) wrong++;

    print('${(number + 1).toString().padLeft(2)} '
        '${puzzle.name.padRight(18)} '
        '${puzzle.rings} rings  '
        'fewest $walk  the smith says $smith  '
        'written down ${puzzle.fewest}'
        '${agree ? '' : '  WRONG'}');
  }

  if (wrong > 0) {
    print('\n$wrong puzzle${wrong == 1 ? '' : 's'} wrong');
    throw StateError('the shipped puzzles are not what they claim');
  }
}
