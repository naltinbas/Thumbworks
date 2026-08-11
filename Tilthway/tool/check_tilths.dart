// A command line tool whose whole job is to print. It is not part of any game.
// ignore_for_file: avoid_print

import 'package:tilthway/tilth/rules.dart';
import 'package:tilthway/tilth/tilths.dart';

/// Walks every shipped tilth and prints the ledger the README quotes.
///
/// Run with: dart run tool/check_tilths.dart  (or `make tilths`)
void main() {
  // The uniqueness first: at every size to ten, exactly one winnable
  // board, and it is the unsown one.
  for (var seeds = 1; seeds <= 10; seeds++) {
    final winners = <String>[];
    for (final board in Rules.allBoards(seeds, 6)) {
      if (Rules.canWin(board)) winners.add(board.join(','));
    }
    if (winners.length != 1 ||
        winners.single != Rules.unsown(seeds).join(',')) {
      throw StateError('uniqueness fails at $seeds seeds');
    }
  }
  print('at every size to ten, exactly one board wins, and it is the '
      'unsown one\n');

  var wrong = 0;
  for (var number = 0; number < Tilths.count; number++) {
    final tilth = Tilths.at(number);
    final wins = Rules.canWin([...tilth.board]);

    final agree = wins == tilth.winnable;
    if (!agree) wrong++;

    print('${(number + 1).toString().padLeft(2)} '
        '${tilth.name.padRight(19)} '
        '${tilth.seeds.toString().padLeft(2)} seeds  '
        'board ${tilth.board.join("-")}  '
        '${wins ? "plays home" : "dead where it lies"}'
        '${agree ? '' : '  WRONG'}');
  }

  if (wrong > 0) {
    print('\n$wrong tilth${wrong == 1 ? '' : 's'} wrong');
    throw StateError('the shipped tilths are not what they claim');
  }
}
