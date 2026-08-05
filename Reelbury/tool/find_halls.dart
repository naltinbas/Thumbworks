// A command line tool whose whole job is to print. It is not part of the game.
// ignore_for_file: avoid_print

import 'dart:math';

import 'package:reelbury/reel/hall.dart';
import 'package:reelbury/reel/stable.dart';

/// Looks for halls where only one pairing holds, and prints them.
///
/// Run with: dart run tool/find_halls.dart [size] [how many]
///
/// A hall where two pairings hold is no puzzle: both answers are right, so
/// there is nothing to work out. Most halls are like that, and the bigger
/// they are the worse it gets, which is what the counting at the end says.
void main(List<String> args) {
  final size = args.isEmpty ? 5 : int.parse(args.first);
  final wanted = args.length > 1 ? int.parse(args[1]) : 4;
  final dice = Random(size * 1000 + wanted);

  var tried = 0;
  var kept = 0;
  var most = 0;

  while (kept < wanted && tried < 20000) {
    tried++;
    final hall = Hall(
      callers: [
        for (var who = 0; who < size; who++)
          ([for (var other = 0; other < size; other++) other]..shuffle(dice)),
      ],
      dancers: [
        for (var who = 0; who < size; who++)
          ([for (var other = 0; other < size; other++) other]..shuffle(dice)),
      ],
    );

    final all = Stable.allThatHold(hall);
    if (all.length > most) most = all.length;
    if (all.length != 1) continue;

    // A hall where the one pairing hands everybody their first choice is not
    // a puzzle, it is a queue. So is one where nearly everybody gets it.
    var firsts = 0;
    for (var caller = 0; caller < size; caller++) {
      if (hall.callers[caller].first == all.first[caller]) firsts++;
    }
    if (firsts > size ~/ 3) continue;
    kept++;

    print('--- one pairing holds ---');
    print('      callers: [');
    for (final order in hall.callers) {
      print('        [${order.join(', ')}],');
    }
    print('      ],');
    print('      dancers: [');
    for (final order in hall.dancers) {
      print('        [${order.join(', ')}],');
    }
    print('      ],');
    print('      answer: ${all.first}   ($firsts got their first choice)');
  }

  print('');
  print('kept $kept of $tried halls of $size; the most pairings any of them '
      'held was $most');
}
