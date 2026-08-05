// A command line tool whose whole job is to print. It is not part of the game.
// ignore_for_file: avoid_print

import 'package:winnowmere/sift/fewest.dart';
import 'package:winnowmere/sift/noughts.dart';

/// Works out the fewest comparators that will sort a given number of lines.
///
/// Run with: dart run tool/fewest.dart [most lines]
///
/// These are the numbers everybody else has: 1, 3, 5, 9, 12, 16 for two lines
/// up to seven. Nothing here reads them from anywhere; they come out of a
/// walk over every network there is, with networks that leave the same set of
/// rows behind counted once. Seven takes about a minute and a half.
void main(List<String> args) {
  final most = args.isEmpty ? 6 : int.parse(args.first);

  for (var lines = 2; lines <= most; lines++) {
    final began = DateTime.now();
    final found = Fewest.forLines(lines);
    final took = DateTime.now().difference(began).inMilliseconds;

    if (found == null) {
      print('$lines lines: not settled');
      continue;
    }
    print('$lines lines: ${found.$1} comparators, ${took}ms, '
        'and it sorts: ${Noughts.sorts(found.$2)}');
    print('    ${found.$2.crosses.join('  ')}');
  }
}
